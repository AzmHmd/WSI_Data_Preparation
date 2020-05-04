import os
import pickle
import numpy as np
import pandas as pd
from PIL import Image
from PIL import ImageDraw
from PIL import ImageColor
import math
import PolyscopeSDK


def polyscope_dots_to_labels(obj, image_dimension):
    if obj is None:
        obj = PolyscopeSDK.PolyscopeSDK()
    if not obj.is_tile:
        obj.output_dir.joinpath('celllabels', obj.file_name[:-3] + obj.file_format).mkdir(exist_ok=True,
                                                                                          parents=True)
    else:
        obj.output_dir.joinpath('celllabels').mkdir(exist_ok=True, parents=True)

    if not obj.is_tile:
        obj.output_dir.joinpath('AnnotatedTiles', obj.file_name[:-3] + obj.file_format).mkdir(exist_ok=True,
                                                                                              parents=True)
    else:
        obj.output_dir.joinpath('AnnotatedTiles').mkdir(exist_ok=True, parents=True)

    df = obj.txt_to_df(annotation_type='6')

    if not obj.is_tile:
        labels = pickle.load(open(str(obj.path_to_param), 'rb'))
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

    divisor = np.float64(slide_w)  # PolZoomer annotations are normalized by width

    df['xf'] = (df['x1'].astype(float)) * divisor
    df['yf'] = (df['y1'].astype(float)) * divisor

    c_to_label = {}
    with open(str(obj.class_labels_path)) as labels:
        for line in labels:
            a = line.split(' ')
            c_to_label[a[0]] = a[1].strip('\n')

    df['class_label'] = ''
    count = {'total': 0}
    for index, row in df.iterrows():
        df.loc[index, 'class_label'] = c_to_label.get(df.loc[index, 'color'])
        if c_to_label.get(df.loc[index, 'color']) in count:
            count[c_to_label.get(df.loc[index, 'color'])] += 1
        else:
            count[c_to_label.get(df.loc[index, 'color'])] = 1

    counts = pd.DataFrame([count])
    counts['total'] = counts.sum(axis=1)
    counts.to_csv(str(obj.output_dir.joinpath(obj.file_name[:-4] + '_label_counts.csv')), index=False)

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

            curr_df = df[(df['yf'].between(start_h, end_h, inclusive=True))
                         & (df['xf'].between(start_w, end_w, inclusive=True))]
            if not curr_df.empty:
                if obj.is_tile:
                    im = Image.open(os.path.join(str(obj.cws_path), obj.file_name[:-3] + 'jpg'))
                else:
                    im = Image.open(os.path.join(str(obj.cws_path), obj.file_name[:-3] + obj.file_format,
                                                 'Da' + str(iter_tot_tiles) + '.jpg'))
                curr_df.is_copy = False
                temp_yf = round(curr_df.loc[:, 'yf']) - start_h
                temp_xf = round(curr_df.loc[:, 'xf']) - start_w
                temp_yf = temp_yf.astype(int)
                temp_xf = temp_xf.astype(int)
                curr_df.loc[:, 'yf'] = temp_yf
                curr_df.loc[:, 'xf'] = temp_xf
                draw = ImageDraw.Draw(im)
                for index, row in curr_df.iterrows():
                    draw.ellipse((row['xf'] - 5, row['yf'] - 5, row['xf'] + 5, row['yf'] + 5),
                                 fill=ImageColor.getrgb('#' + row['color']))
                curr_df = curr_df[['class_label', 'xf', 'yf']]
                curr_df.rename(columns={'class_label': 'V1', 'xf': 'V2', 'yf': 'V3'},
                               inplace=True)
                if obj.is_tile:
                    curr_df.to_csv(os.path.join(str(obj.output_dir), 'celllabels', obj.file_name[:-3] + 'csv'),
                                   index=False)
                    im.save(os.path.join(str(obj.output_dir), 'AnnotatedTiles', obj.file_name[:-3] + 'jpg'))
                else:
                    curr_df.to_csv(os.path.join(str(obj.output_dir), 'celllabels', obj.file_name[:-3] + obj.file_format,
                                                'Da' + str(iter_tot_tiles) + '.csv'), index=False)
                    df.to_csv(os.path.join(str(obj.output_dir), 'celllabels', obj.file_name[:-3] + obj.file_format,
                                           'FullDa' + str(iter_tot_tiles) + '.csv'), index=False)
                    im.save(os.path.join(str(obj.output_dir), 'AnnotatedTiles', obj.file_name[:-3] + obj.file_format,
                                         'Da' + str(iter_tot_tiles) + '.jpg'))
            iter_tot_tiles += 1
