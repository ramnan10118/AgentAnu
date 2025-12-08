import dotenv from 'dotenv';
dotenv.config();

/**
 * Mock OTP Service for Hackathon
 * Always returns the same OTP for demo purposes
 */

const MOCK_OTP = process.env.MOCK_OTP || '123456';

export const sendOTP = (mobile) => {
  console.log(`📱 Mock OTP sent to ${mobile}: ${MOCK_OTP}`);

  // In a real app, this would integrate with SMS gateway
  // For hackathon, we just log and return success

  return {
    success: true,
    message: 'OTP sent successfully',
    // Don't send OTP in response in production!
    // Only for hackathon demo
    otp: MOCK_OTP
  };
};

export const generateOTP = () => {
  return MOCK_OTP;
};
