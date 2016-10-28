require 'cagnut_toolbox/functions/qseq_to_fastq'

module CagnutToolbox
  class Base
    def qseq2fastq dirs
      opts = { dirs: dirs }
      qseq2fastq = CagnutToolbox::QseqToFastq.new opts
      qseq2fastq.run
    end
  end
end
