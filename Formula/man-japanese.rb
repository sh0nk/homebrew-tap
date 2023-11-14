# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class ManJapanese < Formula
  desc ""
  homepage ""
  url "http://linuxjm.osdn.jp/man-pages-ja-20231115.tar.gz"
  sha256 "ce8bf9d8e6642506a20f82d462ec6de14b5689194df46dacdc5d10bd0a5f5b17"
  license ""

  depends_on "groff"

  # depends_on "cmake" => :build

  resource "installman" do
    url "https://raw.githubusercontent.com/sh0nk/homebrew-tap/main/manj/installman.sh"
    sha256 "ac2dbf29ee50cf283c27470f0a6302e3cd0e7e5817dcc9e34c65f8f7f590ca9a"
  end

  def install
    resource("installman").stage do
      cp("installman.sh", buildpath)
    end

    manj_path = prefix/"manj"/"ja_JP.UTF-8"
    mkdir_p manj_path
    ENV["CELLAR_PATH"] = manj_path
    system "bash", "-e", "installman.sh"

    # Handle man.conf
    cp("/etc/man.conf", buildpath/"manj.conf")
    inreplace "manj.conf" do |s|
      s.gsub!(/^JNROFF.+$/, "JNROFF		#{Formula["groff"].opt_bin}/groff -Dutf8 -Tutf8 -mandoc -mja -E")
      s.gsub!(/^PAGER.+$/, "PAGER		/usr/bin/less -isr")
      s.gsub!(/^BROWSER.+$/, "BROWSER		/usr/bin/less -isr")
    end
    etc.install "manj.conf"

    # Prepare bin
    (buildpath/"manj").write <<~EOS
      #!/bin/sh
      env LANG=ja_JP.UTF-8 MANPATH=#{manj_path.to_s}:$MANPATH man -C #{etc.to_s}/manj.conf $@
    EOS
    bin.install "manj"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test man-pages-ja`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
