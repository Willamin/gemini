# class Crem::Gemini::InvalidStatusCode < Exception; end
#
# enum Crem::Gemini::Status
#   Input
#   SensitiveInput
#   Success
#   RedirectTemporary
#   RedirectPermanent
#   TemporaryFailure
#   ServerUnavailable
#   CgiError
#   ProxyError
#   SlowDown
#   PermanentFailure
#   NotFound
#   Gone
#   ProxyRequestRefused
#   BadRequest
#   ClientCertificateRequired
#   CertificateNotAuthorised
#   CertificateNotValid
#
#   def self.from_i32?(value : Int32) : self?
#     self.from_i32!(value)
#   rescue e : InvalidStatusCode
#     return nil
#   end
#
#   def self.from_i32!(value : Int32) : self
#     case value
#     when 10 then Input
#     when 11 then SensitiveInput
#     when 20 then Success
#     when 30 then RedirectTemporary
#     when 31 then RedirectPermanent
#     when 40 then TemporaryFailure
#     when 41 then ServerUnavailable
#     when 42 then CgiError
#     when 43 then ProxyError
#     when 44 then SlowDown
#     when 50 then PermanentFailure
#     when 51 then NotFound
#     when 52 then Gone
#     when 53 then ProxyRequestRefused
#     when 59 then BadRequest
#     when 60 then ClientCertificateRequired
#     when 61 then CertificateNotAuthorised
#     when 62 then CertificateNotValid
#     else
#       raise InvalidStatusCode.new
#     end
#   end
#
#   def to_i32 : Int32
#     case self
#     in Input                     then 10
#     in SensitiveInput            then 11
#     in Success                   then 20
#     in RedirectTemporary         then 30
#     in RedirectPermanent         then 31
#     in TemporaryFailure          then 40
#     in ServerUnavailable         then 41
#     in CgiError                  then 42
#     in ProxyError                then 43
#     in SlowDown                  then 44
#     in PermanentFailure          then 50
#     in NotFound                  then 51
#     in Gone                      then 52
#     in ProxyRequestRefused       then 53
#     in BadRequest                then 59
#     in ClientCertificateRequired then 60
#     in CertificateNotAuthorised  then 61
#     in CertificateNotValid       then 62
#     end
#   end
# end
