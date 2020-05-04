import os
import PolyscopeSDK
import pathlib


def run(opts_in):
    annotations_dir = opts_in['annotations_dir']
    cws_path = opts_in['cws_path']
    output_dir = opts_in['output_dir']
    file_format = opts_in['file_format']
    is_tile = opts_in['is_tile']
    class_labels_path = opts_in['class_labels_path']

    annotation_files = sorted(list(pathlib.Path(annotations_dir).glob('*.txt')))
    
    if not pathlib.Path(output_dir).is_dir():
        os.makedirs(output_dir, exist_ok=True)

    print(len(annotation_files))
    for i in range(0, len(annotation_files)):
        print(len(annotation_files))

        curr_file = annotation_files[i].parts[-1]
        '''print(curr_file, flush=True)'''
        SDK = PolyscopeSDK.PolyscopeSDK(file_name=curr_file,
                                        cws_path=cws_path, annotations_dir=annotations_dir, output_dir=output_dir,
                                        file_format=file_format, class_labels_path=class_labels_path, is_tile=is_tile)
        SDK.polyscope_rectangles_to_labels()


if __name__ == '__main__':
    opts = {
        'annotations_dir': '/home/azamhamidinekoo/Documents/DeepLearing/020120_QC/Annotation_extraction/annotations/annotation-Extraction',
        'cws_path': '/home/azamhamidinekoo/Documents/DeepLearing/020120_QC/Annotation_extraction/cws',
        'output_dir': '/home/azamhamidinekoo/Documents/DeepLearing/020120_QC/Annotation_extraction/rect_negative',
        'file_format': 'czi',
        'is_tile': False,  # If the annotations are on tiles (is_tile = True) or wsi image (is_tile = False)
        'class_labels_path': 'HEBlack.txt'}
    run(opts_in=opts)
