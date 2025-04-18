import os
import subprocess
import time

from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from PyPDF2 import PdfReader, PdfWriter
from tqdm import tqdm

pdf2zh = "pdf2zh"  # 设置pdf2zh指令: 默认为'pdf2zh'
thread_num = 4  # 设置线程数: 默认为4
translated_dir = (
    "/Users/atosh/.tmp/pdf2zh"  # 设置翻译文件的临时输出路径(注意: 使用绝对路径!)
)
port_num = 5237  # 设置端口号: 默认为8888

config_path = "config.json"  # 添加配置文件: 自定义字体, 指定翻译引擎等

lang_in = "en"  # 设置输入语言: 默认为'en'
lang_out = "ja"  # 设置输出语言: 默认为'ja'

service = "groq"  # 设置翻译引擎: 默认为'gemini'

prompt = "prompt.txt"

app = FastAPI()


class TranslationRequest(BaseModel):
    filePath: str


@app.post("/translate")
async def translate(data: TranslationRequest):
    input_path = data.filePath
    try:
        os.makedirs(translated_dir, exist_ok=True)
        print("=== Translating ===: ", input_path)

        # 入力PDFのページ数を取得
        pdf = PdfReader(input_path)
        num_pages = len(pdf.pages)

        # ページごとに処理して、それぞれのページを抜き出して結合
        mono_output_writer = PdfWriter()
        dual_output_writer = PdfWriter()

        with tqdm(total=num_pages, desc="Translating PDF", unit="page") as pbar:
            for page_num in range(num_pages):
                # ページごとにpdf2zhを実行
                os.chdir(os.path.dirname(os.path.abspath(__file__)))
                os.system(
                    f'{pdf2zh} "{input_path}" -o {translated_dir} -t {thread_num} -p {page_num + 1} -lo ja --prompt {prompt} -s {service} --config {config_path}'
                )

                # ページごとの結果を取得
                temp_mono_path = os.path.join(
                    translated_dir,
                    os.path.basename(input_path).replace(".pdf", "-mono.pdf"),
                )
                temp_dual_path = os.path.join(
                    translated_dir,
                    os.path.basename(input_path).replace(".pdf", "-dual.pdf"),
                )

                # ページごとの結果を結合
                with open(temp_mono_path, "rb") as temp_mono_file:
                    mono_output_writer.add_page(PdfReader(temp_mono_file).pages[page_num])

                # dualの場合は2ページごとに抽出
                with open(temp_dual_path, "rb") as temp_dual_file:
                    temp_dual_pdf = PdfReader(temp_dual_file)
                    dual_output_writer.add_page(temp_dual_pdf.pages[page_num * 2])
                    dual_output_writer.add_page(temp_dual_pdf.pages[page_num * 2 + 1])

                pbar.update(1)


        # 結合したPDFを出力
        translated_path1 = os.path.join(
            translated_dir, os.path.basename(input_path).replace(".pdf", "-mono.pdf")
        )
        translated_path2 = os.path.join(
            translated_dir, os.path.basename(input_path).replace(".pdf", "-dual.pdf")
        )
        with open(translated_path1, "wb") as output_file:
            mono_output_writer.write(output_file)
        with open(translated_path2, "wb") as output_file:
            dual_output_writer.write(output_file)

        return JSONResponse(
            content={
                "status": "success",
                "translatedPath1": translated_path1,
                "translatedPath2": translated_path2,
            },
            status_code=status.HTTP_200_OK,
        )

    except subprocess.CalledProcessError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"status": "error", "message": e.stderr},
        )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="localhost", port=5327)
