# routes/family.py — Family Portfolio Endpoints

from fastapi import APIRouter, HTTPException, status
from models.family import FamilySummaryResponse, FamilyMember
from services.family_service import get_family_summary, get_member

router = APIRouter(prefix="/portfolio", tags=["Family Portfolio"])


@router.get(
    "/family-summary",
    response_model=FamilySummaryResponse,
    summary="Get aggregated family net worth",
)
def family_summary():
    """
    **GET /portfolio/family-summary**

    Returns the combined net worth of all family members,
    plus individual breakdowns by member.
    """
    return get_family_summary()


@router.get(
    "/member/{member_id}",
    response_model=FamilyMember,
    summary="Get individual family member portfolio",
)
def member_portfolio(member_id: str):
    """
    **GET /portfolio/member/{member_id}**

    Valid member IDs: `self`, `spouse`, `parent_father`, `parent_mother`
    """
    try:
        return get_member(member_id)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
