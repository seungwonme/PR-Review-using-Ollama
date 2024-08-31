import requests
import json
import re
import sys

HOST = sys.argv[1]
MODEL = sys.argv[2]
FILENAME = sys.argv[3]
PROMPT = sys.argv[4]

with open(FILENAME, "r", encoding="utf-8") as file:
    code_content = file.read()

prompt = f"{PROMPT}\n\n{code_content}"

payload = json.dumps({"prompt": prompt, "model": MODEL, "stream": False})

response = requests.post(
    f"{HOST}/api/generate",
    data=payload,
    headers={"Content-Type": "application/json"},
)

pattern = r'"response":"(.*?)","done"'
match = re.search(pattern, response.text, re.DOTALL)

if match:
    response_body = match.group(1)
    print(response_body)
else:
    print("Response not found")
