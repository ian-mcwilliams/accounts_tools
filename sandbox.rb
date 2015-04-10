require_relative('file_tools')

output = [
    %w[one two three],
    %w[four five six],
    %w[seven eight nine]
]

FileTools.write_output_to_excel('sample_file.xlsx', 'test_sheet2', output)