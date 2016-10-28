module CagnutToolbox
  class QseqToFastq
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :dodebug,
                   :jobs_dir, :ref_fasta, :seqs_path, :prefix_name
    def_delegators :'CagnutToolbox.config', :exe_path

    def initialize opts = {}
      @input = opts[:input].nil? ? "#{seqs_path}" : opts[:input]
      @input.gsub! '.gz', ''
      @input2 = File.expand_path fetch_filename, File.dirname(@input)
      abort('Cant recognized sequence files') if @input2.nil?
      @output = "#{opts[:dirs][output]}/#{sample_name}_1_qtf.fastq"
      @output2 = "#{opts[:dirs][output]}/s_#{sample_name}_2_qtf.fastq"
      @job_name = "#{prefix_name}_qseq_to_fastq_#{sample_name}"
    end

    def fetch_filename
      filename = File.basename(@input)
      if filename.match '_R1_'
        filename.gsub '_R1_', '_R2_'
      elsif filename.match '_1_'
        filename.gsub '_1_', '_2_'
      end
    end

    def run previous_job_id = nil
      puts "Submitting #{sample_name} qseqToFastq"
      script_name = generate_script task
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      [@job_name, @output]
    end

    def queuing_options previous_job_id = nil
      {
        previous_job_id: previous_job_id,
        tools: ['toolbox', 'qseq_to_fastq']
      }
    end

    def generate_script
      script_name = 'toolbox_qseq2fastq'
      exe_qseq_to_fastq = "ruby #{exe_path}/qseq_to_fastq.rb"
      file = File.join jobs_dir, "#{script_name}.sh"
      File.open(file, 'w') do |f|
        f.puts <<-BASH.strip_heredoc
          #!/bin/bash

          cd "#{jobs_dir}/../"
          echo "#{script_name} is starting at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
          if [ -s "#{@input}.gz" ]
          then
            gunzip -c #{@input}.gz | #{exe_qseq_to_fastq} #{@output} \\
              #{::Cagnut::JobManage.run_local}
            gunzip -c #{@input2}.gz | #{exe_qseq_to_fastq} #{@output2} \\
              #{::Cagnut::JobManage.run_local}
          else
            cat #{@input} | #{exe_qseq_to_fastq} #{@output} \\
              #{::Cagnut::JobManage.run_local}
            cat #{@input2} | #{exe_qseq_to_fastq} #{@output2} \\
              #{::Cagnut::JobManage.run_local}
          fi

          #force error when missing/empty fastq . Would prevent continutation of pipeline
          if [ ! -s "#{@output2}" ]
          then
            echo "Missing FASTQ: #{@output2} file!"
            exit 100
          fi
          echo "#{script_name} is finished at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"

        BASH
      end
      File.chmod(0700, file)
    end
  end
end
