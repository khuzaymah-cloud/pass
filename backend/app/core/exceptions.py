from fastapi import HTTPException, status


class AppException(HTTPException):
    def __init__(self, detail: str, status_code: int = status.HTTP_400_BAD_REQUEST):
        super().__init__(status_code=status_code, detail=detail)


class SubscriptionNotActiveError(AppException):
    def __init__(self, detail: str = "Subscription is not active"):
        super().__init__(detail=detail, status_code=status.HTTP_403_FORBIDDEN)


class SubscriptionExpiredError(AppException):
    def __init__(self, detail: str = "Subscription has expired"):
        super().__init__(detail=detail, status_code=status.HTTP_403_FORBIDDEN)


class GymTierNotAllowedError(AppException):
    def __init__(self, detail: str = "Gym tier not allowed for your plan"):
        super().__init__(detail=detail, status_code=status.HTTP_403_FORBIDDEN)


class DuplicateCheckinError(AppException):
    def __init__(self, detail: str = "Already checked in at this gym today"):
        super().__init__(detail=detail, status_code=status.HTTP_409_CONFLICT)


class OTPRateLimitError(AppException):
    def __init__(self, detail: str = "Too many OTP requests"):
        super().__init__(detail=detail, status_code=status.HTTP_429_TOO_MANY_REQUESTS)


class OTPLockoutError(AppException):
    def __init__(self, detail: str = "Account locked due to failed attempts"):
        super().__init__(detail=detail, status_code=status.HTTP_429_TOO_MANY_REQUESTS)


class OTPInvalidError(AppException):
    def __init__(self, detail: str = "Invalid OTP code"):
        super().__init__(detail=detail, status_code=status.HTTP_401_UNAUTHORIZED)


class PaymentNotFoundError(AppException):
    def __init__(self, detail: str = "Payment not found"):
        super().__init__(detail=detail, status_code=status.HTTP_404_NOT_FOUND)


class CountryNotFoundError(AppException):
    def __init__(self, detail: str = "Country not found"):
        super().__init__(detail=detail, status_code=status.HTTP_404_NOT_FOUND)
