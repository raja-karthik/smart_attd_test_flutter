class SliderModel {
  String imageAssetPath;
  String title;
  String desc;

  SliderModel({this.imageAssetPath, this.title, this.desc});

  void setImageAssetPath(String getImageAssetPath) {
    imageAssetPath = getImageAssetPath;
  }

  void setTitle(String getTitle) {
    title = getTitle;
  }

  void setDesc(String getDesc) {
    desc = getDesc;
  }

  String getImageAssetPath() {
    return imageAssetPath;
  }

  String getTitle() {
    return title;
  }

  String getDesc() {
    return desc;
  }
}

List<SliderModel> getSlides() {
  List<SliderModel> slides = new List<SliderModel>();
  SliderModel sliderModel = new SliderModel();

  //1
  sliderModel.setDesc("Attendance using facial recognition");
  sliderModel.setTitle("Simple, Secure & Smart");
  sliderModel.setImageAssetPath("assets/images/onboarding_1.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //2
  sliderModel
      .setDesc("Easily mark your attendance anytime, anywhere, and on the go");
  sliderModel.setTitle("Record");
  sliderModel.setImageAssetPath("assets/images/onboarding_2.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //3
  sliderModel
      .setDesc("Take control of your work schedule, check your overall stats");
  sliderModel.setTitle("Stats");
  sliderModel.setImageAssetPath("assets/images/onboarding_3.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  return slides;
}
