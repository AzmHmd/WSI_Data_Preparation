import os
import pickle
import numpy as np
import math
from PIL import Image
from PIL import ImageDraw
from PIL import ImageColor
import PolyscopeSDK
import pandas as pd


def polyscope_freehand_to_labels(obj, image_dimension):
    if obj is None:
        obj = PolyscopeSDK.PolyscopeSDK()

    if not obj.is_tile:
        obj.output_dir.joinpath('freehandlabels', obj.file_name[:-3] + obj.file_format).mkdir(exist_ok=True, parents=True)
    else:
        obj.output_dir.joinpath('freehandlabels').mkdir(exist_ok=True, parents=True)

    if not obj.is_tile:
        obj.output_dir.joinpath('AnnotatedTiles', obj.file_name[:-3] + obj.file_format).mkdir(exist_ok=True, parents=True)
    else:
        obj.output_dir.joinpath('AnnotatedTiles').mkdir(exist_ok=True, parents=True)

    df = obj.txt_to_df(annotation_type='4')

    if not obj.is_tile:
        labels = pickle.load(open(str(obj.path_to_param), 'rb'))
        # print(labels)
        slide_dimension = np.array(labels['slide_dimension']) / labels['rescale']
        slide_h = slide_dimension[1]
        slide_w = slide_dimension[0]
        cws_read_size = labels['cws_read_size']
        cws_h = cws_read_size[0]
        cws_w = cws_read_size[1]
    else:
        slide_h = image_dimension[1]
        slide_w = image_dimension[0]
        cws_h = image_dimension[1]
        cws_w = image_dimension[0]

    c_to_label = {}
    with open(str(obj.class_labels_path)) as labels:
        for line in labels:
            a = line.split(' ')
            c_to_label[a[0]] = a[1].strip('\n')

    df['class_label'] = ''
    for index, row in df.iterrows():
        df.loc[index, 'class_label'] = c_to_label.get(df.loc[index, 'color'])

    xydf = []
    xydf_keys = []
    divisor = np.float64(slide_w)  # PolZoomer annotations are normalized by width
    for index, row in df.iterrows():
        txt_tuple = df.loc[index, 'tuples']
        list_tuples = list(map(tuple, np.float64(eval("[%s]" % txt_tuple)) * divisor))
        xydf.append(pd.DataFrame.from_records(list_tuples, columns=['x', 'y']))
        xydf_keys.append(str(index))
    all_tuple_df = pd.concat(xydf, keys=xydf_keys, names=['Series keys'])

    iter_tot_tiles = 0
    for h in range(int(math.ceil((slide_h - cws_h) / cws_h + 1))):
        for w in range(int(math.ceil((slide_w - cws_w) / cws_w + 1))):
            start_h = h * cws_h
            start_w = w * cws_w

            end_h = start_h + cws_h
            end_w = start_w + cws_w

            if end_h > slide_h:
                end_h = slide_h

            if end_w > slide_w:
                end_w = slide_w

            if obj.is_tile:
                im = Image.open(os.path.join(str(obj.cws_path), obj.file_name[:-3] + 'jpg'))
            else:
                im = Image.open(os.path.join(str(obj.cws_path), obj.file_name[:-3] + obj.file_format,
                                             'Da' + str(iter_tot_tiles) + '.jpg'))

            im = process_curr_df(obj, im, df, all_tuple_df, iter_tot_tiles, start_h, start_w, end_h, end_w)

            iter_tot_tiles += 1


def process_curr_df(obj, im, df, all_tuple_df, iter_tot_tiles, start_h, start_w, end_h, end_w):

    curr_df = all_tuple_df[(all_tuple_df['y'].between(start_h, end_h, inclusive=True))
                 & (all_tuple_df['x'].between(start_w, end_w, inclusive=True))]

    if not curr_df.empty:
        indices = curr_df.index.get_level_values('Series keys').unique()
        draw = ImageDraw.Draw(im)
        imb = Image.fromarray(np.zeros(shape=np.array(im).shape).astype('uint8'))
        draw_imb = ImageDraw.Draw(imb)
        for index in indices:
            curr_df = all_tuple_df.xs(index, level=0)

            if not curr_df.empty:
                curr_df = curr_df[(curr_df['y'].between(start_h, end_h, inclusive=True))
                                  & (curr_df['x'].between(start_w, end_w, inclusive=True))]
                curr_df.is_copy = False
                temp_y = round(curr_df.loc[:, 'y']) - start_h
                temp_x = round(curr_df.loc[:, 'x']) - start_w
                temp_y = temp_y.astype(int)
                temp_x = temp_x.astype(int)

                curr_tuple = tuple(zip(list(temp_x), list(temp_y)))
                draw.polygon(xy=curr_tuple, outline=ImageColor.getrgb('#' + df.loc[int(index), 'color']))
                draw_imb.polygon(xy=curr_tuple, outline=ImageColor.getrgb('#' + df.loc[int(index), 'color']),
                                 fill=ImageColor.getrgb('#' + df.loc[int(index), 'color']))

        if obj.is_tile:
            im.save(os.path.join(str(obj.output_dir), 'AnnotatedTiles', obj.file_name[:-3] + 'jpg'))
            imb.save(os.path.join(str(obj.output_dir), 'freehandlabels', obj.file_name[:-3] + 'jpg'))
        else:
            im.save(os.path.join(str(obj.output_dir), 'AnnotatedTiles', obj.file_name[:-3] + obj.file_format,
                                 'Da' + str(iter_tot_tiles) + '.jpg'))
            imb.save(os.path.join(str(obj.output_dir), 'freehandlabels', obj.file_name[:-3] + obj.file_format,
                                 'Da' + str(iter_tot_tiles) + '.jpg'))

    return im
