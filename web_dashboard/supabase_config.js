// File: web_dashboard/supabase_config.js
// Cấu hình kết nối Supabase cho Web App của bạn
// Hãy cập nhật các giá trị supabaseUrl và supabaseKey từ Supabase Project API Settings (Project Settings -> API)

const supabaseUrl = 'https://cbeodxxygxxkwngvykxe.supabase.co';
const supabaseKey = 'sb_publishable_4S6nSfs5jkDKi-oLetpotw_sS5TviIt';

// Khởi tạo Supabase Client
const supabaseClient = supabase.createClient(supabaseUrl, supabaseKey);
