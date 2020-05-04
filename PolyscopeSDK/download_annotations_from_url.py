import urllib3
import shutil
import os
import pathlib


def run(url_csv):
    url_list = str(pathlib.Path(url_csv))
    save_path, _ = os.path.split(url_list)
    http = urllib3.PoolManager()
    with open(url_list) as url_txt:
        for url in url_txt:
            with http.request('GET', url.strip('\n'), preload_content=False) as r, open('index.html', 'wb') as out_file:
                shutil.copyfileobj(r, out_file)

            break_next = False
            with open('index.html', 'r') as inF:
                for line in inF:
                    if break_next:
                        id, _ = line.split('\n')
                        try:
                            id, _ = line.split('deepzoom.dzi\n')
                        except ValueError:
                            pass  # does nothing
                        # print(a)
                        break
                    else:
                        if '<td>' in line:
                            break_next = True
            
            with open('index.html', 'r') as inF:
                for line in inF:
                    if 'tileSources:     ".' in line:
                        p = line
                        # print(a)
                        break

            _, anno_path, _ = p.split('"')
            path, _ = os.path.split(url)
            full_path = path + anno_path[1:-4] + '_files' '/annotations.txt'

            filename = os.path.join('./downloadedAnnotations/' + id + '.txt')

            with http.request('GET', full_path, preload_content=False) as r, open(filename, 'wb') as out_file:
                shutil.copyfileobj(r, out_file)


if __name__ == '__main__':
    url_csv_path = 'list.csv'
    run(url_csv=url_csv_path)
