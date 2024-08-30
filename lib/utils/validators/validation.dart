class DValidator{

  static String? validationEmail(String? value){
    if (value == null || value.isEmpty) {
      return 'Please enter your first name';
    }

    // Regular expression for email address validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if(!emailRegExp.hasMatch(value)){
      return 'Invalid email address';
    }

    return null;
  }

  // static String? valida

}