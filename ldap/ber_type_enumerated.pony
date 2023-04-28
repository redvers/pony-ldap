use "debug"
use "format"
use "collections"

primitive BERTypeEnumerated
  fun encode(x: U64): Array[U8] val ? =>
//    Debug.out("Encoding: " + x.string())
    if (false) then error end
    if (x == 0) then return [ 0x0a ; 0x01 ; 0x00 ] end

    let ax: Array[U8] trn = recover trn Array[U8].init(0, 8) end
    var bytewidth: USize = 0
    ifdef littleendian then
      ax.update_u64(0, x.bswap())?
    else
      ax.update_u64(0, x)?
    end
    while (bytewidth < 7) do
      if (((ax(bytewidth)? == 0x00)) and ((ax(bytewidth + 1)? == 0x00))) then
//        Debug.out("Two 0xffs")
        bytewidth = bytewidth + 1
        continue
      end
//      Debug.out("bw: " + bytewidth.string() + ": " + ax(bytewidth)?.string())
      if (((ax(bytewidth)? == 0x00)) and ((ax(bytewidth + 1)? and 0b10000000) == 0b10000000)) then
//        Debug.out("Last negative field")
        break
      end
      if ((ax(bytewidth)? == 0x00)) then
        bytewidth = bytewidth + 1
        continue
      end
//      if ((mask == 0) and ((ax(bytewidth)? and 0b10000000) == 0b10000000)) then
//        bytewidth = bytewidth - 1
//        break
//      end
      break
    end

    let aax: Array[U8] trn = recover trn Array[U8] end
    aax.push(0x0a)
    aax.push(8 - bytewidth.u8())
    aax.append((consume ax).trim(bytewidth))
//    var aaaa: Array[U8] val = consume aax
//    display(aaaa)
    consume aax

  fun display(s: Array[U8] val) =>
    let t: String trn = recover trn String end
    for f in s.values() do
      t.append(Format.int[U8](f where fmt = FormatHexBare, prec = 2) + " ")
    end
//    Debug.out(consume t)

  fun decode(inc: Array[U8] val): (U64, Array[U8] val) ? =>
//    display(inc)
    (let len: U32, let data: Array[U8] val) = BERSize.decode(inc.trim(1))?
    let ax: Array[U8] trn = recover trn Array[U8].init(0, 8) end
    for f in Range(USize(0), len.usize()) do
      ax.update((8 - len.usize()) + f, data(f)?)?
    end
    if ((ax(8 - len.usize())? and 0b10000000) == 0b10000000) then
      for ff in Range(USize(0), 8 - len.usize()) do
        ax.update(ff, 0xff)?
      end
    end
    ifdef littleendian then
      let aaaa: U64 = (consume ax).read_u64(0)?.bswap()
//      Debug.out("Decoded:  " + aaaa.string())
      return (aaaa, data.trim(len.usize()))
    else
      return ((consume ax).read_u64(0)?, data.trim(len.usize()))
    end

