class JPEG
  attr_reader :width, :height, :bits

  def initialize(file)
    examine(file)
  end

private
  def examine(io)
    raise 'malformed JPEG' unless io.getbyte == 0xFF && io.getbyte == 0xD8 # SOI

    class << io
      def readint; (getbyte << 8) + getbyte; end
      def readframe; read(readint - 2); end
      def readsof; [readint, getbyte, readint, readint, getbyte]; end
      def next
        c = getbyte while c != 0xFF
        c = getbyte while c == 0xFF
        c
      end
    end

    while marker = io.next
      case marker
        when 0xC0..0xC3, 0xC5..0xC7, 0xC9..0xCB, 0xCD..0xCF # SOF markers
          length, @bits, @height, @width, components = io.readsof
          raise 'malformed JPEG' unless length == 8 + components * 3
        when 0xD9, 0xDA
          break # EOI, SOS
        when 0xFE
          @comment = io.readframe # COM
        when 0xE1
          io.readframe # APP1, contains EXIF tag
        else
          io.readframe # ignore frame
      end
    end
  end
end