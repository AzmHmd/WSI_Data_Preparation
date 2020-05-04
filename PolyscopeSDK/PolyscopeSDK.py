import os
import pathlib
from subpackages import txt_to_df
from subpackages import cws_tile_annotations_to_wsi_polyscope
from subpackages import cws_tile_annotations_to_tile_polyscope
from subpackages import polyscope_dots_to_labels
from subpackages import polyscope_rectangles_to_labels
from subpackages import polyscope_freehand_to_labels


class PolyscopeSDK:
    def __init__(self,
                 cws_path=os.getcwd(),
                 results_dir=os.getcwd(),
                 output_dir=os.getcwd(),
                 annotations_dir=os.getcwd(),
                 class_labels_path='class_labels.txt',
                 file_name='',
                 file_format='',
                 is_tile=True):
        self.cws_path = pathlib.Path(cws_path).resolve()
        self.is_tile = is_tile
        self.results_dir = pathlib.Path(results_dir).resolve()
        self.output_dir = pathlib.Path(output_dir).resolve()
        if not self.is_tile:
            self.path_to_param = self.cws_path.joinpath(file_name[:-3] + file_format, 'param.p')
        else:
            self.path_to_param = None

        self.annotations_path = pathlib.Path(annotations_dir, file_name)
        self.class_labels_path = pathlib.Path(class_labels_path)
        self.file_name = file_name
        if is_tile:
            self.file_format = None
        else:
            self.file_format = file_format

    def txt_to_df(self, annotation_type):
        df = txt_to_df.txt_to_df(obj=self, annotation_type=annotation_type)
        return df

    def cws_tile_annotations_to_wsi_polyscope(self):
        cws_tile_annotations_to_wsi_polyscope.cws_tile_annotations_to_wsi_polyscope(obj=self)

    def cws_tile_annotations_to_tile_polyscope(self, tile_image_path, mat_path):
        cws_tile_annotations_to_tile_polyscope.cws_tile_annotations_to_tile_polyscope(obj=self,
                                                                                      tile_image_path=tile_image_path,
                                                                                      mat_path=mat_path)

    def polyscope_dots_to_labels(self, image_dimension=(2000, 2000)):
        polyscope_dots_to_labels.polyscope_dots_to_labels(obj=self,
                                                          image_dimension=image_dimension)

    def polyscope_rectangles_to_labels(self, image_dimension=(2000, 2000)):
        polyscope_rectangles_to_labels.polyscope_rectangles_to_labels(obj=self,
                                                                      image_dimension=image_dimension)

    def polyscope_freehand_to_labels(self, image_dimension=(2000, 2000)):
        polyscope_freehand_to_labels.polyscope_freehand_to_labels(obj=self,
                                                                      image_dimension=image_dimension)
