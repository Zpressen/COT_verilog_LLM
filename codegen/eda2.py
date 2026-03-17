import sys, os, json
from dotenv import load_dotenv
from openai import OpenAI
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Assuming PrimisAI Nexus framework is available
try:
    from primisai.nexus.core import Agent
except ImportError:
    print("PrimisAI Nexus not found. Please ensure it's installed or adjust import.")
    sys.exit(1)

load_dotenv()

llm_config = {
    'model': "deepseek-chat",
    'api_key': "sk-69b2599638a24105962d6b186788d6ce",  # Your DeepSeek API key
    'base_url': "https://api.deepseek.com/v1"
}

# Tool function: Simulates Verilog logic (simplified)
def simulate_logic(argument: str):
    try:
        # Placeholder: Simulate logic using Python (use sandbox in production)
        exec(argument)  # WARNING: Use a proper sandbox for security
        return {"status": "success", "output": "Logic simulation successful"}
    except Exception as e:
        return {"status": "error", "output": str(e)}

function_metadata = {
    "type": "function",
    "function": {
        "name": "simulate_logic",
        "description": "Simulate Verilog logic snippet (using Python proxy, not actual Verilog). Used for validation reasoning.",
        "parameters": {
            "type": "object",
            "properties": {
                "argument": {"type": "string", "description": "Python code to simulate Verilog logic."}
            },
            "required": ["argument"]
        }
    }
}

tools = [{"tool": simulate_logic, "metadata": function_metadata}]

def count_tokens(text):
    """Approximate token count using word count"""
    words = text.split()
    return len(words)

def extract_description_and_code(item):
    """
    Extract problem_description by combining the entire input field and instruction.
    Extract output_code from the output field.
    """
    instruction = item.get('instruction', '')
    input_text = item.get('input', '')
    output_code = item.get('output', '')

    # Combine input_text and instruction for problem_description
    problem_description = input_text + '\n\n' + instruction if instruction else input_text

    return problem_description, output_code

# Initialize Agents with concise system messages
analyzer = Agent(
    name="Analyzer",
    system_message="You are a Verilog RTL designer. Extract circuit information from the problem description, aligning with the expected functionality in the output code.",
    llm_config=llm_config
)

planner = Agent(
    name="Planner",
    system_message="You are a Verilog RTL designer. Generate a problem overview and decompose tasks based on Analyzer output and problem description, aligning with the expected functionality in the output code.",
    llm_config=llm_config
)

designer = Agent(
    name="Designer",
    system_message="You are a Verilog RTL designer. Perform signal-specific reasoning and module integration based on Planner output and problem description, aligning with the expected functionality in the output code.",
    llm_config=llm_config
)

validator = Agent(
    name="Validator",
    system_message="You are a Verilog RTL designer. Validate and debug the design from Designer, using tools if needed, based on problem description, ensuring alignment with the expected functionality in the output code.",
    llm_config=llm_config,
    tools=tools,
    use_tools=True
)

# Custom function to coordinate Agents
def coordinate_agents(problem_description, output_code, client):
    """Manually coordinate Agents to generate COT and concatenate outputs"""
    # Step 1: Analyzer - Difficulty assessment and circuit extraction
    analyzer_prompt = """
    You are an expert Verilog RTL designer skilled in chain-of-thought reasoning. In a brief, narrative style, assess the problem difficulty based on the problem description.
    Then, extract only the key circuit information from the problem description, including signals with brief descriptions, and state transition descriptions, formatted as:
    signals: <signal1 name>: <signal1 description>,
    <signal2 name>: <signal2 description>,
    ...,
    state_transitions: <current_state> (<output>) --<input_condition>--> <next_state>, ...
    Align extractions with the expected functionality of the Verilog module described. Provide extraction with brief explanations for each element to inform design choices. 
    The problem description is as follows, {problem_description}
    Ensure the output's thought process remains less rigidly structured, allowing for smoother transitions with preceding text. Avoid detailed lists or excessive state transitions. Prioritize information critical to design and validation. MUST keep your response under 450 tokens.
    """
    analyzer_query = analyzer_prompt.format(problem_description=problem_description, output_code=output_code)
    analyzer_response = client.chat.completions.create(
        model=llm_config['model'],
        messages=[
            {"role": "system", "content": analyzer.system_message},
            {"role": "user", "content": analyzer_query}
        ],
        temperature=0.7,
        max_tokens=600,
    ).choices[0].message.content

    # Step 2: Planner - Problem overview and task decomposition
    planner_prompt = """
    You are an expert Verilog RTL designer skilled in chain-of-thought reasoning. Based on the Analyzer output, summarize the module's functionality and requirements in 1-2 sentences for context, aligning with the expected functionality of the Verilog module. 
    Then, break the implementation into sub-tasks. Focus on one signal or logic block per sub-task, extracting relevant context from the problem description and linking to the extracted circuit information, formatted as:
    subtask_id: 1, content: <task description>;
    subtask_id: 2, content: <task description>;
    ......;
    Make reasoning natural, mimicking a hardware engineer's internal monologue. Ensuring alignment with the expected functionality.
    Problem Description: {problem_description}
    Verilog Code: {output_code}
    Analyzer Output: {analyzer_response}
    Ensure the output's thought process remains less rigidly structured, allowing for smoother transitions with preceding text. MUST keep your response under 500 tokens.
    """
    planner_query = planner_prompt.format(
        problem_description=problem_description,
        output_code=output_code,
        analyzer_response=analyzer_response
    )
    planner_response = client.chat.completions.create(
        model=llm_config['model'],
        messages=[
            {"role": "system", "content": planner.system_message},
            {"role": "user", "content": planner_query}
        ],
        temperature=0.7,
        max_tokens=600
    ).choices[0].message.content

    # Step 3: Designer - Signal-specific reasoning and module integration
    designer_prompt = """
    You are an expert Verilog RTL designer skilled in chain-of-thought reasoning. Using Planner's sub-tasks and extracted circuit information, for each sub-task, reason through the design process, emphasize state transitions for FSMs and adhere to hardware design rules. Base your design entirely on the problem description and extracted information, use the extracted signals, transitions, and examples to enrich reasoning. 
    Then, integrate sub-task code into the complete module, ensuring prior code is preserved and aligns with requirements. Weave reasoning naturally without redundancy. Include brief explanations of design choices and alternatives considered. 
    subtask: 1, content: <reason for subtask 1>;
    subtask: 2, content: <reason for subtask 2>;
    ......;
    Verilog Code: {output_code}
    Analyzer Output: {analyzer_response}
    Planner Output: {planner_response}
    Do not cross-reference or validate your reasoning against the provided Verilog code; focus on a purely independent design process as if you are designing from scratch. Ensure the output's thought process remains less rigidly structured, allowing for smoother transitions with preceding text. MUST keep your response under 500 tokens.
    """
    designer_query = designer_prompt.format(
        problem_description=problem_description,
        output_code=output_code,
        analyzer_response=analyzer_response,
        planner_response=planner_response
    )
    designer_response = client.chat.completions.create(
        model=llm_config['model'],
        messages=[
            {"role": "system", "content": designer.system_message},
            {"role": "user", "content": designer_query}
        ],
        temperature=0.7,
        max_tokens=600  # Increased for detailed reasoning
    ).choices[0].message.content

    # Step 4: Validator - Validation and debugging
    validator_prompt = """
    You are an expert Verilog RTL designer skilled in chain-of-thought reasoning. Based on Designer output, reflect on potential issues (e.g., timing, reset behavior, race conditions, bus contention) and simulate a concise debugging process (e.g., waveform tracing for mismatches, backtracing signals using extracted transitions) to ensure the design matches the expected functionality of the Verilog module. Use tools if needed to simulate logic. Make the reflection natural, concise yet detailed, and consider multiple scenarios or edge cases (e.g., aborted operations, timing violations).
    Problem Description: {problem_description}
    Verilog Code: {output_code}
    Designer Output: {designer_response}
    Ensure the output's thought process remains less rigidly structured, allowing for smoother transitions with preceding text. MUST keep your response under 350 tokens.
    """
    validator_query = validator_prompt.format(
        problem_description=problem_description,
        output_code=output_code,
        designer_response=designer_response
    )
    validator_response = client.chat.completions.create(
        model=llm_config['model'],
        messages=[
            {"role": "system", "content": validator.system_message},
            {"role": "user", "content": validator_query}
        ],
        temperature=0.7,
        max_tokens=450
    ).choices[0].message.content

    # Step 5: Concatenate Agent outputs into final CoT
    final_response = f"""
<think>
First, I will analyze the problem description to evaluate its complexity and extract the essential circuit details that will guide the design process.
{analyzer_response}
Using the analyzed signals and states, I map out the module’s functionality and break it into actionable tasks.
{planner_response}
Next, I translate these tasks into a concrete design, reasoning through signal assignments and state transitions to build the module.
{designer_response}
To confirm the design’s accuracy, I will test its behavior against the requirements and debug potential issues.
{validator_response}
</think>
"""

    return final_response

def process_single_item(item, index, total, results, output_file):
    """Process a single dataset item (single-threaded)"""
    print(f"Processing item {index + 1}/{total}")

    # Create API client
    client = OpenAI(api_key=llm_config['api_key'], base_url=llm_config['base_url'])

    # Extract problem_description and output_code
    problem_description, output_code = extract_description_and_code(item)

    # Coordinate Agents to generate COT
    response = coordinate_agents(problem_description, output_code, client)

    if response:
        try:
            # Parse <think> and </think> tags
            if '<think>' in response and '</think>' in response:
                think_content = response.split('<think>')[1].split('</think>')[0].strip()
            else:
                think_content = response.strip()  # Fallback if tags missing

            # Calculate token count
            token_count = count_tokens(think_content)
            print(f"Item {index + 1} think output token count: {token_count}")

            # Update item with think field
            updated_item = item.copy()
            updated_item['think'] = think_content

            result = {
                "input": item,
                "output": updated_item
            }
        except Exception as e:
            print(f"Failed to parse response: {str(e)}")
            updated_item = item.copy()
            updated_item['think'] = f"Response parsing failed: {str(e)}"
            token_count = count_tokens(updated_item['think'])
            print(f"Item {index + 1} think output token count: {token_count}")
            result = {
                "input": item,
                "output": updated_item
            }
    else:
        updated_item = item.copy()
        updated_item['think'] = "API call failed"
        token_count = count_tokens(updated_item['think'])
        print(f"Item {index + 1} think output token count: {token_count}")
        result = {
            "input": item,
            "output": updated_item
        }

    # Append to results and save
    results.append(result)
    updated_results = [r['output'] for r in results]
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(updated_results, f, indent=2)

    print(f"Item {index + 1} processed")
    return result

def process_dataset(input_file, output_file):
    """Process dataset sequentially (single-threaded)"""
    # Read input data
    with open(input_file, 'r', encoding='utf-8') as f:
        dataset = json.load(f)

    # Convert single object to list if needed
    if not isinstance(dataset, list):
        dataset = [dataset]

    results = []
    total_items = len(dataset)

    # Process each item sequentially
    for i, item in enumerate(dataset):
        process_single_item(item, i, total_items, results, output_file)

    print(f"Processing complete! Results saved to {output_file}")
    return [r['output'] for r in results]

# Example usage
if __name__ == "__main__":
    input_json = "dataset_complete/full_removed.json"  # Your dataset
    output_json = "dataset_complete/generated_cot_agent_dataset.json"
    process_dataset(input_json, output_json)