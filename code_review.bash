#!/bin/bash

usage() {
cat << EOF
Usage: $0 <host> <file> [model]
    <host>  The host where the Ollama API is running.
    <file>  The file to review.
    [model] The model to use for generating the review. Default is "mistral-nemo".
EOF
}

if [ -z "$1" ] || [ -z "$2" ]; then
  usage
  exit 1
fi

make_prompt() {
  cat <<EOF
You are a software developer responsible for code reviews in the engineering department of a technology/software company.
- After reviewing the submitted code, you write a review summarizing your findings.
- Include information such as problems found, recommendations for improvement, areas of strength, and an overall assessment of the code quality.
- Your review should be organized, easy to understand, and provide actionable feedback to the developer.
- Since it's a one-way communication, there's no need to introduce yourself or say hello, just get to the point.
Review the following file:
EOF
}

prompt=$(make_prompt)
host="$1"
file=$(cat "$2")

if [ -z "$3" ]; then
  model="mistral-nemo"
else
  model="$3"
fi

# Escape newlines and double quotes in the prompt and file content
escaped_prompt=$(echo "$prompt" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' | sed 's/"/\\"/g')
escaped_file=$(echo "$file" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' | sed 's/"/\\"/g')

json_payload=$(
  cat <<EOF
{
  "model": "$model",
  "prompt": "$escaped_prompt\\n$escaped_file",
  "stream": false
}
EOF
)

res=$(curl -s $host:11434/api/generate -d "$(echo $json_payload)" | jq .response)

# Remove double quotes from the response
echo "$res" | sed 's/^"//' | sed 's/"$//' > res.txt
echo -e "$(cat res.txt)"
