package model

import jwt "github.com/dgrijalva/jwt-go"

func VulnProbeJWT() bool {
	claims := jwt.MapClaims{"aud": []string{"expected-audience"}}

	return claims.VerifyAudience("expected-audience", true)
}
