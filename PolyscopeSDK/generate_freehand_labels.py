import os
import PolyscopeSDK
import pathlib

annotations_dir = r'../Annotations/Tumour_Marking/20191115'
cws_path = r'‎⁨COPAINGE/ahamidinekoo/RMS-dataset_cws⁩'
output_dir = r'../Annotations/Tumour_Marking/20191115/freehand_labels'
file_format = 'czi'
is_tile = False # If the annotations are on tiles (is_tile = True) or wsi image (is_tile = False)
class_labels_path = 'class_labels_freehand.txt'

annotation_files = sorted(list(pathlib.Path(annotations_dir).glob('*.txt')))

if not pathlib.Path(output_dir).is_dir():
    os.makedirs(output_dir, exist_ok=True)

for i in range(0, len(annotation_files)):
    curr_file = annotation_files[i].parts[-1]
    print(curr_file, flush=True)
    SDK = PolyscopeSDK.PolyscopeSDK(file_name=curr_file,
                                    cws_path=cws_path, annotations_dir=annotations_dir, output_dir=output_dir,
                                    file_format=file_format, class_labels_path=class_labels_path, is_tile=is_tile)
    SDK.polyscope_freehand_to_labels()