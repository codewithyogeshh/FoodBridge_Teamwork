-- ==============================================================================
-- FoodBridge 2.0 - Complete Supabase Backend Schema & RPC Migration
-- Run this script in Supabase SQL Editor (https://app.supabase.com)
-- ==============================================================================

-- 1. Ensure required columns in 'donations' table
ALTER TABLE public.donations 
ADD COLUMN IF NOT EXISTS requires_volunteer_delivery BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS delivery_fee NUMERIC DEFAULT 0.0,
ADD COLUMN IF NOT EXISTS assigned_volunteer_id TEXT,
ADD COLUMN IF NOT EXISTS assigned_volunteer_name TEXT,
ADD COLUMN IF NOT EXISTS reserved_ngo_id TEXT,
ADD COLUMN IF NOT EXISTS reserved_ngo_name TEXT;

-- 2. Create Community Donations Table
CREATE TABLE IF NOT EXISTS public.community_donations (
    id TEXT PRIMARY KEY,
    donor_id TEXT,
    donor_name TEXT NOT NULL,
    donor_phone TEXT NOT NULL,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    quantity_or_amount TEXT NOT NULL,
    pickup_address TEXT NOT NULL,
    condition_rating TEXT,
    is_anonymous BOOLEAN DEFAULT FALSE,
    assigned_ngo_id TEXT,
    assigned_ngo_name TEXT,
    status TEXT NOT NULL DEFAULT 'submitted',
    tax_80g_receipt_number TEXT,
    payment_transaction_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create Storage Bucket for Verification Documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('ngo-documents', 'ngo-documents', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policy to allow authenticated and anon uploads for onboarding
CREATE POLICY "Public Document Uploads" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'ngo-documents');

CREATE POLICY "Public Document Reads" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'ngo-documents');

-- 4. Atomic Concurrency Lock RPC for Food Reservation
CREATE OR REPLACE FUNCTION public.reserve_donation_atomic(
    p_donation_id TEXT,
    p_ngo_id TEXT,
    p_ngo_name TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_status TEXT;
BEGIN
    SELECT status INTO v_status 
    FROM public.donations 
    WHERE id::text = p_donation_id 
    FOR UPDATE;

    IF v_status IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Donation not found');
    END IF;

    IF v_status != 'available' THEN
        RETURN jsonb_build_object('success', false, 'message', 'Donation is already ' || v_status);
    END IF;

    UPDATE public.donations
    SET status = 'reserved',
        reserved_ngo_id = p_ngo_id,
        reserved_ngo_name = p_ngo_name,
        updated_at = NOW()
    WHERE id::text = p_donation_id;

    RETURN jsonb_build_object('success', true, 'message', 'Reserved successfully (Database lock acquired)');
END;
$$;

-- 5. Secure Handover OTP Verification Procedure
CREATE OR REPLACE FUNCTION public.verify_pickup_otp(
    p_donation_id TEXT,
    p_entered_otp TEXT,
    p_ngo_id TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_otp TEXT;
BEGIN
    SELECT pickup_otp INTO v_otp 
    FROM public.donations 
    WHERE id::text = p_donation_id;

    IF v_otp IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Donation record not found');
    END IF;

    IF TRIM(v_otp) = TRIM(p_entered_otp) THEN
        UPDATE public.donations
        SET status = 'pickup_verified',
            updated_at = NOW()
        WHERE id::text = p_donation_id;

        RETURN jsonb_build_object('success', true, 'message', 'Pickup OTP verified successfully');
    ELSE
        RETURN jsonb_build_object('success', false, 'message', 'Invalid OTP code');
    END IF;
END;
$$;

-- 6. Enable Realtime Replication for Tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.donations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.ngos;

