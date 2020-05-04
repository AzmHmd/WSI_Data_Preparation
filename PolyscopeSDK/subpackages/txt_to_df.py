import pandas as pd
import re
import PolyscopeSDK


def txt_to_df(obj, annotation_type):
    if obj is None:
        obj = PolyscopeSDK.PolyscopeSDK()

    df = pd.DataFrame()

    if annotation_type == '2' or annotation_type == '6':
        df = pd.DataFrame(columns=['active', 'index', 'type', 'x1', 'y1', 'x2', 'y2', 'color', '1', 'datetime'])

    if annotation_type == '4':
        df = pd.DataFrame(columns=['active', 'index', 'type', 'tuples', 'color', '1', 'datetime'])

    with open(str(obj.annotations_path)) as annotations:
        for line in annotations:
            if annotation_type == '2' or annotation_type == '6':
                match = re.match(
                    '(\d+),(\d+),(\d+),\[\((\d\.\d*),(\d.\d*)\),\((\d\.\d*),(\d.\d*)\)\],#(\w+),(\d+),(.*)',
                    line)

                if match is not None:
                    g = match.group

                    if g(1) == '1' and g(3) == annotation_type:
                        # print(line)
                        new_list = [[g(1), g(2), g(3), g(4), g(5), g(6), g(7), g(8), g(9), g(10)]]

                        df = df.append(
                            pd.DataFrame(new_list, columns=['active', 'index', 'type', 'x1', 'y1', 'x2', 'y2',
                                                            'color', '1', 'datetime']), ignore_index=True)

            if annotation_type == '4':
                match = re.match('(\d+),(\d+),(\d+),\[(.*)\],#(\w+),(\d+),(.*)', line)
                if match is not None:
                    g = match.group

                    if g(1) == '1' and g(3) == annotation_type:
                        new_list = [[g(1), g(2), g(3), g(4), g(5), g(6), g(7)]]

                        df = df.append(
                            pd.DataFrame(new_list, columns=['active', 'index', 'type', 'tuples', 'color', '1',
                                                            'datetime']), ignore_index=True)

    return df
