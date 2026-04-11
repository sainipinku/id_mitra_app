class Config {
  static String devBaseUrl = "http://stag.idmitra.com/api/";
  static String proBaseUrl = "https://idmitra.com/api/";
  static String baseUrl = proBaseUrl;
  // Base URL without /api/ suffix (for school panel routes)
  static String schoolBaseUrl = "https://idmitra.com/";
}

class Routes {
  static String sendOtp = "auth/send-otp";
  static String otpVerify = "auth/verify-otp";
  static String setCredentails = "auth/profile/set-credentials";
  static String commonStates = "common/states/1";
  static String commonCites(String stateID) => "common/cities/$stateID";
  static String userUploadProfilePhoto = "user/upload-profile-photo";
  static String authLogout = "auth/logout";
  static String leadsFatchData = "leads/fatch-data";
  static String addLeadsData = "leads";
  static String addEvents = "events";
  static String authProfileUpdate = "auth/profile/update";
  static String getPartnerDashboardData() => "auth/partner/dashboard?filter=5_year";
  static String getUserDetails() => "auth/user";
  static String getSchoolList(int pageNo) => "auth/partner/schools?page=$pageNo";
  static String updateStudentProfile(String studentID) => "auth/school/students/$studentID/image";
  static String updateEventLeadsStatus(String eventId) => "events/$eventId/set-active-lead";
  static String getLeadsList(String name,String status) => "leads?search=$name&status=$status";
  static String getEventsList(String name,String status,int pageNo) => "events?search=$name&status=$status&page=$pageNo";
  static String getStudentFormFields(String schoolId) => "auth/partner/school/$schoolId/student-form-fields";
  static String getSchoolFormFields(String schoolId) => "auth/school/$schoolId/form-fields";
  static String updateSchoolStudentFormFields(String schoolId) => "auth/school/$schoolId/form-fields/student";
  static String updateLeadsStatus(String leadsId,String status) => "leads/$leadsId/change-status/$status";
  static String getSubCategoryById(String stateID) => "common/cities/$stateID";
  static String getSubCategoryProductById(String subCatId) => "product/subcategory/$subCatId";
}

