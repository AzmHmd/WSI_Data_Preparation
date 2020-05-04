import os
import pickle
import numpy as np
import math
from PIL import Image
from PIL import ImageDraw
from PIL import ImageColor
import PolyscopeSDK
import pandas as pd


def polyscope_rectangles_to_labels(obj, image_dimension):
    if obj is None:
        obj = PolyscopeSDK.PolyscopeSDK()
    if not obj.is_tile:
        obj.output_dir.joinpath('rectlabels', obj.file_name[:-3] + obj.file_format).mkdir(exist_ok=True, parents=True)
    else:
        obj.output_dir.joinpath('rectlabels').mkdir(exist_ok=True, parents=True)

    if not obj.is_tile:
        obj.output_dir.joinpath('AnnotatedTiles', obj.file_name[:-3] + obj.file_format).mkdir(exist_ok=True, parents=True)
    else:
        obj.output_dir.joinpath('AnnotatedTiles').mkdir(exist_ok=True, parents=True)

    df = obj.txt_to_df(annotation_type='2')

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

    divisor = np.float64(slide_w)  # PolZoomer annotations are normalized by width
    # Initialize Pandas Data Frame

    df['xf1'] = (df['x1'].astype(float)) * divisor
    df['yf1'] = (df['y1'].astype(float)) * divisor
    df['xf2'] = (df['x2'].astype(float)) * divisor
    df['yf2'] = (df['y2'].astype(float)) * divisor

    c_to_label = {}
    with open(str(obj.class_labels_path)) as labels:
        for line in labels:
            a = line.split(' ')
            c_to_label[a[0]] = a[1].strip('\n')

    df['class_label'] = ''
    for index, row in df.iterrows():
        df.loc[index, 'class_label'] = c_to_label.get(df.loc[index, 'color'])

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
            curr_df = None
            for case in range(9):
                im, curr_df = \
                    process_curr_df(obj, im, df, curr_df, case, iter_tot_tiles, start_h, start_w, end_h, end_w)

            iter_tot_tiles += 1


def process_curr_df(obj, im, df, curr_df, case, iter_tot_tiles, start_h, start_w, end_h, end_w):

    if curr_df is None:
        curr_df = pd.DataFrame()

    save_df = curr_df

    if case == 0:
        curr_df = df[(df['yf1'].between(start_h, end_h, inclusive=True))
                     & (df['xf1'].between(start_w, end_w, inclusive=True))]
    if case == 1:
        curr_df = df[(df['yf2'].between(start_h, end_h, inclusive=True))
                     & (df['xf1'].between(start_w, end_w, inclusive=True))]

    if case == 2:
        curr_df = df[(df['yf1'].between(start_h, end_h, inclusive=True))
                     & (df['xf2'].between(start_w, end_w, inclusive=True))]

    if case == 3:
        curr_df = df[(df['yf2'].between(start_h, end_h, inclusive=True))
                     & (df['xf2'].between(start_w, end_w, inclusive=True))]

    if case == 4:
        curr_df = df[(df['yf1'].between(start_h, end_h, inclusive=True))
                     & (df['xf1'] < start_w) & (df['xf2'] > end_w)]

    if case == 5:
        curr_df = df[(df['yf2'].between(start_h, end_h, inclusive=True))
                     & (df['xf1'] < start_w) & (df['xf2'] > end_w)]

    if case == 6:
        curr_df = df[(df['xf1'].between(start_w, end_w, inclusive=True))
                     & (df['yf1'] < start_h) & (df['yf2'] > end_h)]

    if case == 7:
        curr_df = df[(df['xf2'].between(start_w, end_w, inclusive=True))
                     & (df['yf1'] < start_h) & (df['yf2'] > end_h)]

    if case == 8:
        curr_df = df[(df['xf1'] < start_w) & (df['xf2'] > end_w)
                     & (df['yf1'] < start_h) & (df['yf2'] > end_h)]

    if not curr_df.empty:
        curr_df.is_copy = False
        temp_yf_1 = round(curr_df.loc[:, 'yf1']) - start_h
        temp_xf_1 = round(curr_df.loc[:, 'xf1']) - start_w
        temp_yf_2 = round(curr_df.loc[:, 'yf2']) - start_h
        temp_xf_2 = round(curr_df.loc[:, 'xf2']) - start_w

        if case == 0:
            temp_xf_2[list(temp_xf_2 > end_w - start_w)] = end_w - start_w - 1
            temp_yf_2[list(temp_yf_2 > end_h - start_h)] = end_h - start_h - 1

        if case == 1:
            temp_xf_2[list(temp_xf_2 > end_w - start_w)] = end_w - start_w - 1
            temp_yf_1[list(temp_yf_1 < 0)] = 0

        if case == 2:
            temp_yf_2[list(temp_yf_2 > end_h - start_h)] = end_h - start_h - 1
            temp_xf_1[list(temp_xf_1 < 0)] = 0

        if case == 3:
            temp_yf_1[list(temp_yf_1 < 0)] = 0
            temp_xf_1[list(temp_xf_1 < 0)] = 0

        if case == 4:
            temp_xf_1[list(temp_xf_1 <= 0)] = 0
            temp_xf_2[list(temp_xf_2 > end_w - start_w)] = end_w - start_w - 1
            temp_yf_2[list(temp_yf_2 > end_h - start_h)] = end_h - start_h - 1

        if case == 5:
            temp_xf_1[list(temp_xf_1 <= 0)] = 0
            temp_xf_2[list(temp_xf_2 > end_w - start_w)] = end_w - start_w - 1
            temp_yf_1[list(temp_yf_1 <= 0)] = 0

        if case == 6:
            temp_yf_1[list(temp_yf_1 <= 0)] = 0
            temp_yf_2[list(temp_yf_2 > end_h - start_h)] = end_h - start_h - 1
            temp_xf_2[list(temp_xf_2 > end_w - start_w)] = end_w - start_w - 1

        if case == 7:
            temp_yf_1[list(temp_yf_1 <= 0)] = 0
            temp_yf_2[list(temp_yf_2 > end_h - start_h)] = end_h - start_h - 1
            temp_xf_1[list(temp_xf_1 <= 0)] = 0

        if case == 8:
            temp_xf_1[list(temp_xf_1 <= 0)] = 0
            temp_xf_2[list(temp_xf_2 > end_w - start_w)] = end_w - start_w - 1
            temp_yf_1[list(temp_yf_1 <= 0)] = 0
            temp_yf_2[list(temp_yf_2 > end_h - start_h)] = end_h - start_h - 1

        temp_yf_1 = temp_yf_1.astype(int)
        temp_xf_1 = temp_xf_1.astype(int)
        temp_yf_2 = temp_yf_2.astype(int)
        temp_xf_2 = temp_xf_2.astype(int)

        curr_df.loc[:, 'yf1'] = temp_yf_1
        curr_df.loc[:, 'xf1'] = temp_xf_1
        curr_df.loc[:, 'yf2'] = temp_yf_2
        curr_df.loc[:, 'xf2'] = temp_xf_2

        draw = ImageDraw.Draw(im)
        for index, row in curr_df.iterrows():
            xy = (row['xf1'], row['yf1'], row['xf2'], row['yf2'])
            for i in range(2):
                draw.rectangle(xy=xy,
                               outline=ImageColor.getrgb('#' + row['color']))
                xy = (xy[0] + 1, xy[1] + 1, xy[2] + 1, xy[3] + 1)

        curr_df = curr_df[['class_label', 'xf1', 'yf1', 'xf2', 'yf2']]
        save_df = save_df.append(curr_df)
        save_df.drop_duplicates(inplace=True)

        # im.show()
        if obj.is_tile:
            save_df.to_csv(os.path.join(str(obj.output_dir), 'rectlabels', obj.file_name[:-3] + 'csv'),
                           index=False)
            im.save(os.path.join(str(obj.output_dir), 'AnnotatedTiles', obj.file_name[:-3] + 'jpg'))
        else:
            # curr_df.rename(columns={'class_label': 'V1', 'xf': 'V2', 'yf': 'V3'},
            #                inplace=True)
            save_df.to_csv(os.path.join(str(obj.output_dir), 'rectlabels', obj.file_name[:-3] + obj.file_format,
                                        'Da' + str(iter_tot_tiles) + '.csv'), index=False)
            # df.to_csv(os.path.join(str(obj.output_dir), 'rectlabels', obj.file_name[:-3] + obj.file_format,
            #                        'FullDa' + str(iter_tot_tiles) + '.csv'), index=False)
            im.save(os.path.join(str(obj.output_dir), 'AnnotatedTiles', obj.file_name[:-3] + obj.file_format,
                                 'Da' + str(iter_tot_tiles) + '.jpg'))

    return im, save_df
