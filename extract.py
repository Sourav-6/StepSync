import json
import os

log_file = r'C:\Users\soura\.gemini\antigravity-ide\brain\5d1cec83-7c5b-4691-a454-e899371c2027\.system_generated\logs\transcript.jsonl'
output_dir = r'C:\Users\soura\Desktop\SampleStepUp\firebase_backup'
os.makedirs(output_dir, exist_ok=True)

with open(log_file, 'r', encoding='utf-8') as f:
    for line in f:
        if 'replace_file_content' in line:
            try:
                data = json.loads(line)
                if 'tool_calls' in data:
                    for tc in data['tool_calls']:
                        if tc['name'] == 'replace_file_content':
                            args = tc['args']
                            if 'TargetFile' in args and 'TargetContent' in args:
                                target_file = args['TargetFile'].strip('"\'')
                                original_content = args['TargetContent'].strip('"\'')
                                
                                base_name = os.path.basename(target_file)
                                out_path = os.path.join(output_dir, base_name)
                                if not os.path.exists(out_path):
                                    # Since TargetContent in transcript is exactly the code string we passed,
                                    # but it was double encoded as JSON inside the log, actually `args['TargetContent']` is the raw string!
                                    # Let's replace the literal \n with newlines if they are escaped
                                    original_content = original_content.encode('utf-8').decode('unicode_escape')
                                    with open(out_path, 'w', encoding='utf-8') as out_f:
                                        out_f.write(original_content)
            except Exception as e:
                print("Error:", e)
