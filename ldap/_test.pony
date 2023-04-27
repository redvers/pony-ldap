use "format"
use "debug"
use "pony_test"
use "pony_check"

actor \nodoc\ Main is TestList
  let env: Env
  new create(env': Env) =>
    env = env'
    PonyTest(env, this)


//  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_BERSizeTests)
    test(_BERTypeBooleanTests)
    test(_BERTypeOctetStringTests)
    test(Property1UnitTest[U32](_BERSizePropertyTests))

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

    let testval: Array[U8] trn = recover trn Array[U8] end
    testval.>append(BERTypeOctetString.encode("Hello "))
    testval.>append(BERTypeOctetString.encode("World"))
    (var a: Array[U8] val, var b: Array[U8] val) = BERTypeOctetString.decode(consume testval)?
    (var c: Array[U8] val, var d: Array[U8] val) = BERTypeOctetString.decode(b)?
    h.assert_array_eq[U8]("Hello ".array(), a)
    h.assert_array_eq[U8]("World".array(), c)
    h.assert_array_eq[U8]([], d)


class \nodoc\ iso _BERSizePropertyTests is Property1[U32]
  fun name(): String => "BERSizePropertyTests"

  fun gen(): Generator[U32] =>
    Generators.u32()

  fun property(arg1: U32, ph: PropertyHelper)? =>
    let a: Array[U8] val = BERSize.encode(arg1)
    let b: U32 = BERSize.decode(a)?._1
    ph.assert_true(arg1 == b)





