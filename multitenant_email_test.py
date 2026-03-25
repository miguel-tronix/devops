# test-multi-tenant.py
import smtplib
import time
from kubernetes import client, config


class MultiTenantEmailTester:
    def __init__(self):
        config.load_kube_config()
        self.v1 = client.CoreV1Api()

    def send_test_email(self, from_tenant, to_tenant, subject, body):
        """Send email between tenants"""

        # Get the mail service endpoint
        mail_service = f"mail.{to_tenant}.svc.cluster.local"

        # Construct email
        from_addr = f"test@{from_tenant}.test"
        to_addr = f"user1@{to_tenant}.test"

        email_text = f"""From: {from_addr}
To: {to_addr}
Subject: {subject}

{body}
"""

        try:
            # Connect and send
            server = smtplib.SMTP(mail_service, 25)
            server.sendmail(from_addr, [to_addr], email_text)
            server.quit()
            print(f"✅ Email sent from {from_tenant} to {to_tenant}")
            return True
        except Exception as e:
            print(f"❌ Failed to send from {from_tenant} to {to_tenant}: {e}")
            return False

    def run_cross_tenant_test(self):
        """Test all tenant combinations"""
        tenants = ["tenant-a", "tenant-b", "tenant-c"]
        results = []

        print("Running cross-tenant email tests...\n")

        for from_t in tenants:
            for to_t in tenants:
                if from_t != to_t:
                    result = self.send_test_email(
                        from_t,
                        to_t,
                        f"Test from {from_t} to {to_t}",
                        f"This is a test email from namespace {from_t} to {to_t}\nTime: {time.ctime()}",
                    )
                    results.append({"from": from_t, "to": to_t, "success": result})
                    time.sleep(0.5)  # Small delay to avoid overwhelming

        # Summary
        print("\n" + "=" * 50)
        print("TEST SUMMARY")
        print("=" * 50)
        for r in results:
            status = "✓" if r["success"] else "✗"
            print(f"{status} {r['from']} -> {r['to']}")

        success_count = sum(1 for r in results if r["success"])
        print(f"\nSuccess rate: {success_count}/{len(results)}")


if __name__ == "__main__":
    tester = MultiTenantEmailTester()
    tester.run_cross_tenant_test()
