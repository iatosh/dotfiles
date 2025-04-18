import os
import subprocess

from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel

pdf2zh = "pdf2zh"  # 设置pdf2zh指令: 默认为'pdf2zh'
thread_num = 4  # 设置线程数: 默认为4
translated_dir = (
    "/Users/atosh/.tmp/pdf2zh"  # 设置翻译文件的临时输出路径(注意: 使用绝对路径!)
)
port_num = 5237  # 设置端口号: 默认为8888

config_path = "config.json"  # 添加配置文件: 自定义字体, 指定翻译引擎等

lang_in = "en"  # 设置输入语言: 默认为'en'
lang_out = "ja"  # 设置输出语言: 默认为'ja'

service = "deepl"  # 设置翻译引擎: 默认为'gemini'

prompt = "prompt.txt"

app = FastAPI()


class TranslationRequest(BaseModel):
    filePath: str


@app.post("/translate")
async def translate(data: TranslationRequest):
    input_path = data.filePath
    try:
        os.makedirs(translated_dir, exist_ok=True)
        print("### translating ###: ", input_path)

        # 执行带配置文件的pdf2zh翻译, 用户可以自定义命令内容:
        os.chdir(os.path.dirname(os.path.abspath(__file__)))
        # os.system(
        #     f'{pdf2zh} "{input_path}" -o {translated_dir} -t {thread_num} -lo ja -p 1 --prompt {prompt} -s {service} --config {config_path}'
        # )

        os.system(
            f'{pdf2zh} "{input_path}" -o {translated_dir} -t {thread_num} -lo ja -s {service} --config {config_path}'
        )

        translated_path1 = os.path.join(
            translated_dir, os.path.basename(input_path).replace(".pdf", "-mono.pdf")
        )
        translated_path2 = os.path.join(
            translated_dir, os.path.basename(input_path).replace(".pdf", "-dual.pdf")
        )

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
