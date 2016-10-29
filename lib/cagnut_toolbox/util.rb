module CagnutToolbox
  class Util
    attr_accessor :toolbox, :config

    def initialize configure
      @config = configure
      @toolbox = CagnutToolbox::Base.new
    end

    def qseq2fastq dirs, order=1
      if check_files
        job_name, filename = toolbox.qseq2fastq dirs, order
        [job_name, filename, order+1]
      else
        [nil, nil, order]
      end
    end

    private

    def check_files
      tilesqseq? && check_incomplete_fastq
    end

    def tilesqseq?
      @config['data_type'] == 'TILESQSEQ'
    end

    def check_incomplete_fastq
      file = fetch_filename @config['seqs_path'][sample]
      !File.size? file
    end

    def fetch_filename file
      filename = File.basename(@file)
      if filename.match '_R1_'
        filename.gsub '_R1_', '_R2_'
      elsif filename.match '_1_'
        filename.gsub '_1_', '_2_'
      end
    end
  end
end
