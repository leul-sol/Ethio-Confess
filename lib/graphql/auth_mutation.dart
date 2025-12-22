const String signupMutation = r'''
mutation Signup($email: String!, $password: String!, $phoneNo: String!, $username: String!) {
  signup(
    user: {
      email: $email
      password: $password
      phone_no: $phoneNo
      username: $username
    }
  ) {
    message
  }
}
''';

const String loginMutation = r'''
mutation Login($usernameOremail: String!, $password: String!) {
  login(
    loginInfo: {
      password: $password, 
      usernameOremail: $usernameOremail
    }
  ) {
    accessToken
  }
}
''';
const String getResetCodeMutation = r'''
mutation GetResetCode($email: String!) {
  getResetCode(email: $email) {
    message
  }
}
''';

const String verifyCodeMutation = r'''
mutation VerifyCode($code: String!,$email: String!) {
  verifyCode(code:$code,email: $email) {
    message
  }
}
''';
const String resetPasswordMutation = r'''
mutation ResetPassword($code: String!,$email: String!,$newPassword:String!) {
  resetPassword(code:$code,email: $email,newPassword:$newPassword) {
    message
  }
}
''';

const String updatePasswordMutation = r'''
mutation UpdatePassword($currentPassword: String!, $email: String!, $newPassword: String!) {
  updatePassword(currentPassword: $currentPassword, email: $email, newPassword: $newPassword) {
    message
  }
}
''';

const String updateUserOneSignalIdMutation = r'''
mutation UpdateUserOneSignalId(
  $id: uuid!,
  $playerId: String!
) {
  update_users_by_pk(pk_columns: {id: $id}, _set: {onesignal_player_id: $playerId}) {
    id
    onesignal_player_id
    username
  }
}
''';
