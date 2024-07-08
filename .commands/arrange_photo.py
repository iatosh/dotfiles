import argparse
import configparser
import glob
import json
import os
import re
import shutil
import string
from collections import defaultdict
from datetime import datetime

from exiftool import ExifTool
from tqdm import tqdm

from tools.spinner import Spinner

DEFAULT_OUTPUT_BASE_PATH = "../OutBox"
DEFAULT_FILENAME_FORMAT = "{y}/{m}/{y}-{m}-{d}_{H}-{M}-{S}"
INPUT_BASE_PATH = ""
IF_COPY = False


def parse_datetime(createdate):
    """CreatedDateを扱いやすい形に分解する."""
    try:
        cdt = datetime.strptime(createdate[:19], "%Y:%m:%d %H:%M:%S")
        return dict(
            y=cdt.strftime("%Y"),
            m=cdt.strftime("%m"),
            d=cdt.strftime("%d"),
            H=cdt.strftime("%H"),
            M=cdt.strftime("%M"),
            S=cdt.strftime("%S"),
        )
    except Exception:
        # 不正な日付は0に置き換えする
        return dict(
            y="0000",
            m="00",
            d="00",
            H="00",
            M="00",
            S="00",
        )


def is_same_photo(photo1_path, photo2_path):
    """Check if two photos are the same based on their exif information."""
    with ExifTool(common_args=[]) as et:
        try:
            # 両方の写真からEXIF情報を取得
            metadata1 = et.execute_json(photo1_path)[0]
            metadata2 = et.execute_json(photo2_path)[0]

            # 比較する重要なEXIF タグのリスト
            important_tags = [
                "DateTimeOriginal",
                "CreateDate",
                "Make",
                "Model",
                "LensModel",
                "ExposureTime",
                "FNumber",
                "ISO",
                "FocalLength",
                "FileSize",
                "ImageWidth",
                "ImageHeight",
            ]

            # 重要なタグの値を比較
            for tag in important_tags:
                if metadata1.get(tag) != metadata2.get(tag):
                    return False
            return True
        except Exception as e:
            tqdm.write(f"Error with {photo1_path}: {e}")
            return True


def get_newpath(output_base_path, filename_format, photo_info):
    """枝番を求める.

    同一ファイル名のファイルがある場合枝番をカウントアップする.
    枝番は0から始まる

    """
    re_name = (
        f"{filename_format.format(**photo_info)}*.{photo_info['FileTypeExtension']}"
    )
    re_path = os.path.join(output_base_path, re_name)
    files = glob.glob(re_path)
    file_count = len(files)

    # Check if there are any duplicates
    if file_count:
        for fn in files:
            if is_same_photo(photo_info["SourceFile"], fn):
                tqdm.write(f"[Skipped] {photo_info['SourceFile']} ↔︎ {fn}")
                return -1

    new_path = re_path.replace(
        "*",
        "",
    )
    if file_count == 1 and files[0] == new_path:
        new_path = re_path.replace(
            "*",
            "_1",
        )
    elif file_count > 1:
        bn = 1
        bn_search = f"{filename_format.format(**photo_info)}(_[0-9]*).{photo_info['FileTypeExtension']}"
        for fn in files:
            m = re.search(bn_search, fn)
            number = m.group(1) if m else "_0"
            bn = max(bn, int(number.replace("_", "")))
        new_path = re_path.replace("*", f"_{bn + 1}")
    return new_path


def load_configure():
    """入力フォルダにあるsetting.iniファイルより出力設定を読み込む"""
    config_file = os.path.join(INPUT_BASE_PATH, "setting.ini")
    config = configparser.ConfigParser(
        {
            "output_base_path": DEFAULT_OUTPUT_BASE_PATH,
            "filename_format": DEFAULT_FILENAME_FORMAT,
        }
    )
    config.read([config_file])
    filename_format = config.get("DEFAULT", "filename_format")
    output_base_path = os.path.abspath(
        os.path.join(INPUT_BASE_PATH, config.get("DEFAULT", "output_base_path"))
    )

    return filename_format, output_base_path


def copy_outbox(photo):
    """写真のexif属性により適切なフォルダへファイルをコピーする"""
    filename_format, output_base_path = load_configure()  # 設定ファイルの読み込み
    photo_info = defaultdict(lambda: "Unknown")
    photo_info.update(  # 写真の属性を取得
        {k: v.replace(" ", "_") if isinstance(v, str) else v for k, v in photo.items()}
    )
    datetype = [
        "CreateDate",
        "DateCreated",
        "DateTimeOriginal",
        "FileModifyDate",
    ]
    datetime = next(
        (
            photo.get(date)
            for date in datetype
            if photo.get(date)
            and photo.get(date) != "0000:00:00 00:00:00"
            and len(photo.get(date)) > 18
        ),
        "0000:00:00 00:00:00",
    )
    photo_info.update(parse_datetime(datetime))  # 日付の取得

    new_path = get_newpath(output_base_path, filename_format, photo_info)

    if new_path == -1:
        return

    # make dirs
    if not os.path.exists(os.path.dirname(new_path)):
        os.makedirs(os.path.dirname(new_path))

    if IF_COPY:
        shutil.copyfile(photo.get("SourceFile"), new_path)
        shutil.copystat(photo.get("SourceFile"), new_path)
    else:
        shutil.move(photo.get("SourceFile"), new_path)


def get_exif_json(directory):
    spinner = Spinner(
        text="Extracting EXIF information...", etext="Extraction complete.", overwrite=False
    )
    spinner.start()
    with ExifTool(common_args=["-r"]) as et:
        # directory以下のファイルのEXIF情報を取得
        metadata = et.execute_json(directory)
    spinner.stop()

    # 結果をJSON形式で出力
    return metadata


# INPUT_BASE_PATH以下の空ディレクトリを削除
def remove_empty_dirs():
    spinner = Spinner(text="Removing empty directories...", etext="Removal complete.", overwrite=False)
    spinner.start()
    for root, dirs, _ in os.walk(INPUT_BASE_PATH, topdown=False):
        for name in dirs:
            try:
                os.rmdir(os.path.join(root, name))
            except OSError:
                pass
    spinner.stop()


def main(photos):
    """exiftoolが出力するJSONファイルの属性から写真を整理する"""
    for photo in tqdm(
        photos, desc="Arranging photos...", dynamic_ncols=True, unit="files"
    ):
        if "Error" not in photo:
            copy_outbox(photo)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("directory", help="directory of the photos to be arranged")
    parser.add_argument(
        "-c", "--copy", action="store_true", help="copy file instead of moving"
    )
    args, _ = parser.parse_known_args()

    INPUT_BASE_PATH = args.directory
    IF_COPY = args.copy

    # input_json = sys.stdin.read()
    input_json = get_exif_json(INPUT_BASE_PATH)

    main(input_json)

    remove_empty_dirs()
