
import PyPDF2
import sys

def extract_text_from_pdf(pdf_path):
    try:
        with open(pdf_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            text = ""
            for page in reader.pages:
                text += page.extract_text() + "\n"
            return text
    except Exception as e:
        return str(e)

if __name__ == "__main__":
    pdf_path = "/Users/dongyuangao/Desktop/dbm_project_ACID/materials_for_report_later/Module Examinations FS25 students.pdf"
    print(extract_text_from_pdf(pdf_path))
