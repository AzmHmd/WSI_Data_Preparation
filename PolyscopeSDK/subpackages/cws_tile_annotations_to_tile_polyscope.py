import os
import numpy as np
import scipy.io as sio
from datetime import datetime
from PIL import Image


def cws_tile_annotations_to_tile_polyscope(obj, tile_image_path, mat_path):
    image = Image.open(tile_image_path)
    image_dimension = image.size
    image_w = image_dimension[0]

    iter_tot_annotations = 1
    divisor = np.float64(image_w)  # PolZoomer annotations are normalized by width

    text_output = open(os.path.join(obj.results_dir, 'annotations.txt'), 'w')

    mat = sio.loadmat(mat_path)
    mat = mat['mat']
    detection = mat['detection'][0][0]
    detection[:, 0] = detection[:, 0]
    detection[:, 1] = detection[:, 1]
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

    text_output.close()