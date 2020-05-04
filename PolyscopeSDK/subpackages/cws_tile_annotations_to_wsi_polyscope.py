import pickle
import numpy as np
import os
import math
import scipy.io as sio
from datetime import datetime


def cws_tile_annotations_to_wsi_polyscope(obj):
    param = pickle.load(open(obj.path_to_param, 'rb'))
    print(param)
    results_dir = obj.results_dir
    slide_dimension = np.array(param['slide_dimension']) / param['rescale']
    slide_h = slide_dimension[1]
    slide_w = slide_dimension[0]
    cws_read_size = param['cws_read_size']
    cws_h = cws_read_size[0]
    cws_w = cws_read_size[1]

    iter_tot_tiles = 0
    iter_tot_annotations = 1
    divisor = np.float64(slide_w)  # PolZoomer annotations are normalized by width

    annotations_path, _ = os.path.split(os.path.normpath(results_dir))
    text_output = open(os.path.join(annotations_path, 'annotations.txt'), 'w')

    for h in range(int(math.ceil((slide_h - cws_h) / cws_h + 1))):
        for w in range(int(math.ceil((slide_w - cws_w) / cws_w + 1))):
            start_h = h * cws_h
            start_w = w * cws_w

            mat = sio.loadmat(os.path.join(results_dir, 'Da' + str(iter_tot_tiles) + '.mat'))
            mat = mat['mat']
            detection = mat['detection'][0][0]
            detection[:, 0] = detection[:, 0] + start_w
            detection[:, 1] = detection[:, 1] + start_h
            detection = np.divide(np.float64(detection), divisor)
            for d in range(detection.shape[0]):
                format_str = ("%d,%d,%d,[(%.16f,%.16f),(%.16f,%.16f)],%s,%d,%s")
                text_output.write((format_str + '\n') % (1, iter_tot_annotations, 6,
                                                         detection[d, 0], detection[d, 1],
                                                         detection[d, 0], detection[d, 1], '#00ff00', 1,
                                                         datetime.strftime(
                                                             datetime.now(), "X%d/X%m/X%Y/X%H:X%M:X%S").
                                                         replace('X0', 'X').replace('X', '')))

                iter_tot_annotations += 1

            iter_tot_tiles += 1

    text_output.close()