require_relative('file_tools')

def test_gen_results_output_excel(results)
  FileUtils.mkdir('run_results') unless Dir.exists?('run_results')
  files = []
  Dir.glob('run_results/*').each { |file| files << file[file.index('/')+1..file.index('.xlsx')-1] if file.index('run_result_') }
  puts files.inspect
  index = 0
  files.each { |file| index = file[11..file.length].to_i if file[11..file.length].to_i >= index } unless files.empty?
  puts index
  FileTools.write_output_to_excel("run_results/run_result_#{index+1}.xlsx", results)
end

output_sheets = [
    {
        sheet_name:   'sheet_no_1',
        output:       [
            %w[one two three],
            %w[four five six],
            %w[seven eight nine]
        ]
    },
    {
        sheet_name:   'sheet_no_2',
        output:       [
            %w[a b c],
            %w[d e f],
            %w[g h i]
        ]
    },
]


test_gen_results_output_excel(output_sheets)