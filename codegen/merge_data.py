import json

def process_cot_dataset(input_files, output_file):
    """
    Processes multiple JSON dataset files, wraps each 'think' content with <think> and </think> tags,
    prepends it to the 'output' field, removes the 'think' field, and merges all datasets into one JSON file.
    
    Args:
        input_files (list): List of paths to input JSON files (arrays of items).
        output_file (str): Path to save the merged JSON file.
    """
    merged_dataset = []
    
    # Process each input file
    for input_file in input_files:
        print(f"Processing file: {input_file}")
        try:
            # Read the input JSON file
            with open(input_file, 'r', encoding='utf-8') as f:
                dataset = json.load(f)
            
            # Process each item in the dataset
            for item in dataset:
                think_content = item.get('think', '').strip()
                updated_item = item.copy()  # Create a copy to modify
                
                if think_content:
                    # Wrap think content with <think> and </think> tags
                    cot_think = f"<think>\n{think_content}\n</think>"
                    
                    # Get the original output (assuming it's a string)
                    original_output = updated_item.get('output', '')
                    
                    # Prepend the CoT think to the output with a newline separator
                    updated_item['output'] = cot_think + '\n\n' + original_output
                    
                    # Remove the think field
                    updated_item.pop('think', None)
                
                # Add the updated item to the merged dataset
                merged_dataset.append(updated_item)
        except FileNotFoundError:
            print(f"Error: File {input_file} not found. Skipping...")
        except json.JSONDecodeError:
            print(f"Error: File {input_file} is not a valid JSON. Skipping...")
    
    # Write the merged dataset to the output file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(merged_dataset, f, indent=2, ensure_ascii=False)
    
    print(f"All datasets processed and merged. Result saved to {output_file}")

# Usage example
if __name__ == "__main__":
    # List of input JSON files
    input_files = [
        "/home/tanhao/codegen/process_dataset/verilog_descriptions_1n2_filter_clearinput.json",
        
    ]
    output_json = "/home/tanhao/codegen/process_dataset/1n2_filter_clearinput_merged.json"
    
    # Process and merge datasets
    process_cot_dataset(input_files, output_json)