self: super:
{
  chromium = super.chromium.override {
    commandLineArgs="--disable-gpu";
  };
}
