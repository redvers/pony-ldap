primitive BERTypeBoolean
  fun encode(x: Bool): Array[U8] val =>
    if (x == true) then
      [0b00_0_00001 ; 0x01 ; 0xff]
    else
      [0b00_0_00001 ; 0x01 ; 0x00]
    end


  fun decode(inc: Array[U8] val): (Bool, Array[U8] val) ? =>
    if (ArrayU8.eq(inc.trim(0,3), [0b00_0_00001 ; 0x01 ; 0xff])) then return (true, inc.trim(3)) end
    if (ArrayU8.eq(inc.trim(0,3), [0b00_0_00001 ; 0x01 ; 0x00])) then return (false, inc.trim(3)) end
    error


