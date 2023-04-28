use "format"
use "debug"
use "pony_test"
use "pony_check"

actor \nodoc\ Main is TestList
  let env: Env
  new create(env': Env) =>
    env = env'
    PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    test(_BERSizeTests)
    test(_BERTypeBooleanTests)
    test(_BERTypeOctetStringTests)
    test(_BERTypeIntegerTests)
    test(_BERTypeSequenceTests)
    test(_BERTypeSetTests)
    test(_BERTypeMixedTests)
    test(Property1UnitTest[U32](_BERSizePropertyTests))
    test(Property1UnitTest[I64](_BERIntegerPropertyTests))

  fun display(s: Array[U8] val) =>
    let t: String trn = recover trn String end
    for f in s.values() do
      t.append(Format.int[U8](f where fmt = FormatHexBare, prec = 2) + " ")
    end
    Debug.out(consume t)


class \nodoc\ iso _BERSizeTests is UnitTest
  fun name(): String => "BERSize"
  fun apply(h: TestHelper)? =>
    /* Check variable length sizes */
    h.assert_array_eq[U8](BERSize.encode(10), [0x84 ; 0x00 ; 0x00; 0x00; 0x0a ])

    h.assert_eq[U32]          (BERSize.decode([0x83 ; 0x00 ; 0x00; 0x0a ])?._1, 10)
    h.assert_eq[U32]          (BERSize.decode([0x82 ; 0x00 ; 0x0a ])?._1, 10)
    h.assert_eq[U32]          (BERSize.decode([0x81 ; 0x0a ])?._1, 10)
    h.assert_eq[U32]          (BERSize.decode([0x81 ; 0x0a ; 0x47; 0x92 ])?._1, 10)
    h.assert_eq[U32]          (BERSize.decode([0x81 ; 0x0a ; 0x47; 0x92 ])?._2.size().u32(),2)
    h.assert_eq[U8]           (BERSize.decode([0x81 ; 0x0a ; 0x47; 0x92 ])?._2.apply(0)?, 0x47)
    h.assert_eq[U8]           (BERSize.decode([0x81 ; 0x0a ; 0x47; 0x92 ])?._2.apply(1)?, 0x92)
    h.assert_ne[U32]          (BERSize.decode([0x81 ; 0x00 ; 0x00; 0x0a ])?._1, 10)
    h.assert_eq[U32]          (BERSize.decode([0x0a ; 0xff ; 0x03])?._1, 10)
    h.assert_eq[U32]          (BERSize.decode([0x0a])?._1, 10)
    h.assert_eq[U32]          (BERSize.decode([0x00])?._1, 0)

    /* Check for lengths that exceed sensible values (U32) */
    h.assert_error({(): None ? => BERSize.decode([0x80 ; 0x00 ; 0x00; 0x0a ])?._1})
    h.assert_error({(): None ? => BERSize.decode([0x86 ; 0x00 ; 0x00; 0x0a ; 0x0a ; 0x0a ; 0x0a])?._1})

    /* Checking that weirdness isn't occuring around twos-compliment */
    h.assert_array_eq[U8](BERSize.encode(2147483648), [0x84 ; 0x80 ; 0x00; 0x00; 0x00 ])
    h.assert_eq[U32](                  BERSize.decode([0x84 ; 0x80 ; 0x00; 0x00; 0x00 ])?._1, 2147483648)

    h.assert_array_eq[U8](BERSize.encode(4294967295), [0x84 ; 0xFF ; 0xFF; 0xFF; 0xFF ])
    h.assert_eq[U32](                  BERSize.decode([0x84 ; 0xFF ; 0xFF; 0xFF; 0xFF ])?._1, 4294967295)

class \nodoc\ iso _BERTypeBooleanTests is UnitTest
  fun name(): String => "BERTypeBooleanTests"
  fun apply(h: TestHelper)? =>
    /* Check variable length sizes */
    h.assert_true(BERTypeBoolean.decode([1 ; 1 ; 255])?._1)
    h.assert_true(BERTypeBoolean.decode([1 ; 1 ; 255])?._2.size() == 0)

    h.assert_false(BERTypeBoolean.decode([1 ; 1 ; 0])?._1)
    h.assert_true(BERTypeBoolean.decode([1 ; 1 ; 0])?._2.size() == 0)


    h.assert_error({(): None ? => BERTypeBoolean.decode([1 ; 1 ; 42])?})

    h.assert_true(BERTypeBoolean.decode([1 ; 1 ; 255 ; 76 ; 42])?._1)
    h.assert_true(BERTypeBoolean.decode([1 ; 1 ; 255 ; 76 ; 42])?._2.size() == 2)
    h.assert_true(BERTypeBoolean.decode([1 ; 1 ; 255 ; 76 ; 42])?._2.apply(0)? == 76)
    h.assert_true(BERTypeBoolean.decode([1 ; 1 ; 255 ; 76 ; 42])?._2.apply(1)? == 42)


class \nodoc\ iso _BERTypeOctetStringTests is UnitTest
  fun name(): String => "BERTypeOctetStringTests"
  fun apply(h: TestHelper)? =>
    let s: Array[U8] val = [ 0x04 ; 0x06 ; 0x48 ; 0x65 ; 0x6c ; 0x6c ; 0x6f ; 0x21 ; 0x09 ]
    h.assert_array_eq[U8](BERTypeOctetString.decode(s)?._1, [ 0x48 ; 0x65 ; 0x6c ; 0x6c ; 0x6f ; 0x21 ])
    h.assert_array_eq[U8](BERTypeOctetString.decode(s)?._2, [ 0x09 ])

    h.assert_array_eq[U8](BERTypeOctetString.encode("Hello!"), [ 0x04 ; 0x84 ; 0x00 ; 0x00; 0x00; 0x06 ; 0x48 ; 0x65 ; 0x6c ; 0x6c ; 0x6f ; 0x21])


class \nodoc\ iso _BERTypeIntegerTests is UnitTest
  fun name(): String => "BERTypeIntegerTests"
  fun apply(h: TestHelper)? =>
    h.assert_array_eq[U8](BERTypeInteger.encode(0)?, [ 0x02 ; 0x01 ; 0x00 ])
    h.assert_array_eq[U8](BERTypeInteger.encode(50)?, [ 0x02 ; 0x01 ; 0x32 ])
    h.assert_array_eq[U8](BERTypeInteger.encode(50000)?, [ 0x02 ; 0x03 ; 0x00 ; 0xc3 ; 0x50 ])
    h.assert_array_eq[U8](BERTypeInteger.encode(-12345)?, [ 0x02 ; 0x03 ; 0xff ; 0xcf ; 0xc7 ])
    h.assert_array_eq[U8](BERTypeInteger.encode(-1)?, [ 0x02 ; 0x01 ; 0xff ])

    h.assert_eq[I64](BERTypeInteger.decode([ 0x02 ; 0x02 ; 0x0f ; 0xfe])?._1, 4094)
    h.assert_eq[I64](BERTypeInteger.decode([ 0x02 ; 0x02 ; 0xff ; 0xfe])?._1, -2 )
    h.assert_eq[I64](BERTypeInteger.decode([ 0x02 ; 0x01 ; 0x0a ])?._1, 10 )
    h.assert_eq[I64](BERTypeInteger.decode([ 0x02 ; 0x02 ; 0xcf ; 0xc7 ])?._1, -12345)


class \nodoc\ iso _BERTypeSequenceTests is UnitTest
  fun name(): String => "BERTypeSequenceTests"
  fun apply(h: TestHelper) =>
    h.assert_array_eq[U8](BERTypeSequence.encode([0x01 ; 0x02 ; 0x03 ]),
                                                 [ 0x30
                                                   0x84 ; 0x00 ; 0x00 ; 0x00 ; 0x03
                                                   0x01 ; 0x02 ; 0x03
                                                 ])

class \nodoc\ iso _BERTypeSetTests is UnitTest
  fun name(): String => "BERTypeSetTests"
  fun apply(h: TestHelper) =>
    h.assert_array_eq[U8](BERTypeSet.encode([0x01 ; 0x02 ; 0x03 ]),
                                                 [ 0x31
                                                   0x84 ; 0x00 ; 0x00 ; 0x00 ; 0x03
                                                   0x01 ; 0x02 ; 0x03
                                                 ])

class \nodoc\ iso _BERTypeMixedTests is UnitTest
  fun name(): String => "BERMixedTypeTests"
  fun apply(h: TestHelper)? =>
    let testval: Array[U8] trn = recover trn Array[U8] end
    testval.>append(BERTypeOctetString.encode("Hello "))
    testval.>append(BERTypeNull.encode())
    testval.>append(BERTypeBoolean.encode(true))
    testval.>append(BERTypeNull.encode())
    testval.>append(BERTypeBoolean.encode(false))
    testval.>append(BERTypeOctetString.encode("World"))

    (var a: Array[U8] val, var b: Array[U8] val) = BERTypeOctetString.decode(consume testval)?
    h.assert_array_eq[U8]("Hello ".array(), a)
    b = BERTypeNull.decode(b)?
    (var bool: Bool, b) = BERTypeBoolean.decode(b)?
    h.assert_true(bool)
    b = BERTypeNull.decode(b)?
    (bool, b) = BERTypeBoolean.decode(b)?
    h.assert_false(bool)
    (a, b) = BERTypeOctetString.decode(b)?
    h.assert_array_eq[U8]("World".array(), a)
    h.assert_array_eq[U8]([], b)

    let tv2: Array[U8] trn = recover trn Array[U8] end
    tv2
    .>append(BERTypeOctetString.encode("Hello!"))
    .>append(BERTypeBoolean.encode(true))
    .>append(BERTypeInteger.encode(5)?)
    let seq1: Array[U8] val = BERTypeSequence.encode(consume tv2)
    h.assert_array_eq[U8](seq1, [
      0x30 ; 0x84 ; 0x00 ; 0x00 ; 0x00 ; 0x12
      0x04 ; 0x84 ; 0x00 ; 0x00 ; 0x00 ; 0x06 ; 0x48 ; 0x65 ; 0x6c ; 0x6c ; 0x6f ; 0x21 // 12
      0x01 ; 0x01 ; 0xff                                                                // 3
      0x02 ; 0x01 ; 0x05 ])                                                             // 3

    let seq2: Array[U8] trn = recover trn Array[U8] end
    seq2
    .>append(seq1)
    .>append(seq1)
    let seq2val: Array[U8] val = consume seq2
    let seq3: Array[U8] val = BERTypeSequence.encode(seq2val)
    h.assert_array_eq[U8](BERTypeSequence.decode(seq3)?._2, [])
    h.assert_array_eq[U8](BERTypeSequence.decode(seq3)?._1, seq2val)

    h.assert_array_eq[U8](BERTypeSequence.decode(seq2val)?._1, [
      0x04 ; 0x84 ; 0x00 ; 0x00 ; 0x00 ; 0x06 ; 0x48 ; 0x65 ; 0x6c ; 0x6c ; 0x6f ; 0x21 // 12
      0x01 ; 0x01 ; 0xff                                                                // 3
      0x02 ; 0x01 ; 0x05 ])                                                             // 3
    h.assert_array_eq[U8](BERTypeSequence.decode(seq2val)?._2, [
      0x30 ; 0x84 ; 0x00 ; 0x00 ; 0x00 ; 0x12
      0x04 ; 0x84 ; 0x00 ; 0x00 ; 0x00 ; 0x06 ; 0x48 ; 0x65 ; 0x6c ; 0x6c ; 0x6f ; 0x21 // 12
      0x01 ; 0x01 ; 0xff                                                                // 3
      0x02 ; 0x01 ; 0x05 ])                                                             // 3


class \nodoc\ iso _BERSizePropertyTests is Property1[U32]
  fun name(): String => "BERSizePropertyTests"

  fun gen(): Generator[U32] =>
    Generators.u32()

  fun property(arg1: U32, ph: PropertyHelper)? =>
    let a: Array[U8] val = BERSize.encode(arg1)
    let b: U32 = BERSize.decode(a)?._1
    ph.assert_true(arg1 == b)

class \nodoc\ iso _BERIntegerPropertyTests is Property1[I64]
  fun name(): String => "BERIntegerPropertyTests"

  fun gen(): Generator[I64] =>
    Generators.i64() // -68523355105413197 fails? // seed: 249975676

//  fun params(): PropertyParams =>
//    PropertyParams(where num_samples' = 500_000)

  fun property(arg1: I64, ph: PropertyHelper)? =>
    let a: Array[U8] val = BERTypeInteger.encode(arg1)?
    let b: I64 = BERTypeInteger.decode(a)?._1
    ph.assert_true(arg1 == b)

