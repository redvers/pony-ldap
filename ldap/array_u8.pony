use "collections"

primitive ArrayU8
  fun eq(a: Array[U8] val, b: Array[U8] val): Bool =>
    if (a.size() != b.size()) then return false end

    try
      for f in Range(0,a.size()) do
        if (a(f)? != b(f)?) then
          return false
        end
      end
      return true
    end
    false
