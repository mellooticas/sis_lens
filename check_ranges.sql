SELECT spherical_min, spherical_max, cylindrical_min, cylindrical_max, COUNT(*) 
FROM catalog_lenses.lenses 
WHERE deleted_at IS NULL 
GROUP BY 1,2,3,4;
