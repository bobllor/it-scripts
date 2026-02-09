from pathlib import Path
import tempfile as tf
import argparse as ap
import os

def get_children(src: Path | str, *, include_dir: bool = False) -> list[Path]:
    '''Gets all children from a source folder recursively.'''
    src = Path(src)
    out: list[Path] = []

    for child in src.iterdir():
        if not child.is_dir():
            out.append(child.absolute())
        else:
            if include_dir:
                out.append(child.absolute())

            temp_children: list[Path] = get_children(child, include_dir=include_dir)

            out.extend(temp_children.copy())
    
    return out

def get_folder(src: Path | str, folder_name: str, *, match: bool = False) -> Path | None:
    '''Recusively searches for the matching folder name in a source folder.
    It matches the first matching folder and is case insensitive.

    If the folder cannot be found, then it will return None.

    Parameters
    ----------
        src: Path |str
            The source folder to search in.
        
        folder_name: str
            The target folder to search for.
        
        match: bool
            If true, then return the matching folder that contains the given folder name.
            By default this is false, always looking for the exact match.
    '''
    src = Path(src)
    folder_name: str = folder_name.lower()
    path: Path | None = None

    if folder_name.strip() == "":
        return path

    for child in src.iterdir():
        if child.is_dir():
            if child.name.lower() == folder_name:
                return child
            elif match and folder_name in child.name.lower():
                return child
            else:
                path = get_folder(child, folder_name, match=match)

                if path is not None:
                    return path

    return path 

if __name__ == "__main__":
    parser: ap.ArgumentParser = ap.ArgumentParser()

    parser.add_argument("source", nargs=1)
    parser.add_argument("-o", "--output", nargs=1, required=True)
    parser.add_argument("-f", "--folder", nargs="*", required=True)
    parser.add_argument("-m", "--match", action="store_true")

    args: ap.Namespace = parser.parse_args()

    source: Path = args.source[0]
    output: str = args.output[0]
    folders: list[str] = args.folder
    match: bool = args.match or False

    source_children: list[Path] = get_children(source)
    files: list[Path] = []

    for folder in folders:
        folder_path: Path | None = get_folder(source, folder, match=match)

        if folder_path is not None:
            children: list[Path] = get_children(folder_path)

            files.extend(children.copy())
        else:
            print(f"Unable to find '{folder}/' in '{source}/'")
            exit(1)

    if len(files) > 0:
        delete: bool = False
        tmp_dir_path: Path = None
        with tf.TemporaryDirectory(delete=delete) as tmpdir:
            tmp_dir_path = Path(tmpdir)
            
        for file in files:
            tmp_file_path: Path = None
            with tf.NamedTemporaryFile("w", delete=delete) as f1:
                tmp_file_path = Path(f1.name)
                
                with open(file, "r") as f2:
                    f1.write(f2.read())

            os.replace(tmp_file_path, tmp_dir_path / file.name)
        
        os.replace(tmp_dir_path, Path(output))
    else:
        print(f"No files found from the folders")
        exit(0)