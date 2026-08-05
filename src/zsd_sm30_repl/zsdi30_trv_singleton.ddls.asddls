@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Single Entry at Main Page'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zsdi30_trv_singleton
  as select from    I_Language  as lang
    left outer join zsd_travell as _trv1 on 1 = 1
  composition [1..*] of ZSDi30_TRAVEL as _trv
{
  key 1                                as SingletonEntry,
      max(_trv1.local_last_changed_at) as maxlastchangedat,
      _trv // Make association public
}
where
  lang.Language = $session.system_language
