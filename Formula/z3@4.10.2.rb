class Z3AT4102 < Formula
  desc "High-performance theorem prover"
  homepage "https://github.com/Z3Prover/z3"
  url "https://github.com/Z3Prover/z3/archive/z3-4.10.2.tar.gz"
  sha256 "889fd035b833775c8cd2eb4723eb011bf916a3e9bf08ce66b31c548acee7a321"
  license "MIT"
  head "https://github.com/Z3Prover/z3.git", branch: "develop"

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/z3[._-]v?(\d+(?:\.\d+)+)["' >]}i)
  end

  # Has Python bindings but are supplementary to the main library
  # which does not need Python.
  depends_on "python@3.11" => :build

  on_linux do
    depends_on "gcc" # For C++17
  end

  fails_with gcc: "5"

  def install
    python3 = Formula["python@3.11"].opt_bin/"python3.11"
    system python3, "scripts/mk_make.py",
                     "--prefix=#{prefix}",
                     "--python",
                     "--pypkgdir=#{prefix/Language::Python.site_packages(python3)}",
                     "--staticlib"

    cd "build" do
      system "make"
      system "make", "install"
    end

    system "make", "-C", "contrib/qprofdiff"
    bin.install "contrib/qprofdiff/qprofdiff"

    pkgshare.install "examples"
  end

  test do
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lz3",
           pkgshare/"examples/c/test_capi.c", "-o", testpath/"test"
    system "./test"
  end
end
