package example

import com.twitter.finagle.oauth2._

object DataHandler extends DataHandler[User] {
  def validateClient(clientId: String, clientSecret: String, grantType: String): Future[Boolean] =

  def findUser(username: String, password: String): Future[Option[User]]
  def createAccessToken(authInfo: AuthInfo[User]): Future[AccessToken]
  def getStoredAccessToken(authInfo: AuthInfo[User]): Future[Option[AccessToken]]
  def refreshAccessToken(authInfo: AuthInfo[U], refreshToken: String): Future[AccessToken]
  def findAuthInfoByCode(code: String): Future[Option[AuthInfo[U]]]
  def findAuthInfoByRefreshToken(refreshToken: String): Future[Option[AuthInfo[U]]]
  def findClientUser(clientId: String, clientSecret: String, scope: Option[String]): Future[Option[U]]
  def findAccessToken(token: String): Future[Option[AccessToken]]
  def findAuthInfoByAccessToken(accessToken: AccessToken): Future[Option[AuthInfo[U]]]
}
