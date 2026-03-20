class Config {
  static String baseUrl = "https://idmitra.com/api/";
}

class Routes {
  static String sendOtp = "auth/send-otp";
  static String otpVerify = "auth/verify-otp";
  static String commonStates = "common/states/1";
  static String commonCites(String stateID) => "common/cities/$stateID";
  static String userUploadProfilePhoto = "user/upload-profile-photo";
  static String updateProfile = "user/update-profile";
  static String leadsFatchData = "leads/fatch-data";
  static String addLeadsData = "leads";
  static String addEvents = "events";
  static String getEventDelete(String eventId) => "events/$eventId";
  static String updateEventLeadsStatus(String eventId) => "events/$eventId/set-active-lead";
  static String getLeadsList(String name,String status) => "leads?search=$name&status=$status";
  static String getEventsList(String name,String status,int pageNo) => "events?search=$name&status=$status&page=$pageNo";
  static String updateLeadsStatus(String leadsId,String status) => "leads/$leadsId/change-status/$status";
  static String getSubCategoryById(String stateID) => "common/cities/$stateID";
  static String getSubCategoryProductById(String subCatId) => "product/subcategory/$subCatId";
}
