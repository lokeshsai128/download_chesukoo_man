from flask import Flask, render_template, request, redirect, url_for
import subprocess
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/download', methods=['POST'])
def download():
    video_link = request.form['video_link']
    download_type = request.form['download_type']
    quality = request.form['quality']

    script_path = os.path.join(os.getcwd(), 'download_script.sh')

    print(f"Received request to download {download_type}.")
    print(f"Video link: {video_link}")
    print(f"Quality: {quality}")
    print(f"Script path: {script_path}")

    try:
        result = subprocess.run(
            ['bash', script_path, video_link, download_type, quality],
            capture_output=True, text=True
        )
        print("Script STDOUT:", result.stdout)
        print("Script STDERR:", result.stderr)

        if result.returncode != 0:
            print(f"Script failed with return code {result.returncode}")
            return "Error: Script failed. Please try again later.", 500

    except Exception as e:
        print(f"Exception occurred: {e}")
        return "An unexpected error occurred. Please try again later.", 500

    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=False)  # Disable debug mode in production
