
UPDATE organization
  SET group_id = org_group.id
  FROM org_group
  where organization.pg = org_group.FOXPRO_KOD;
