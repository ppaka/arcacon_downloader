import imageio
import imageio_ffmpeg
import ffmpeg
import sys


def convertFile(inputpath, outputpath, palettepath):
    reader = imageio.get_reader(inputpath)
    fps = reader.get_meta_data()['fps']

    # print(outputpath + '원본 fps: ' + str(fps))
    while fps > 50:
        fps = fps/2
        # print('조정 fps: ' + str(fps))

    ffmpeg.input(inputpath).filter(filter_name='palettegen').output(palettepath, loglevel='error').global_args(
        '-hide_banner').overwrite_output().run(cmd=imageio_ffmpeg.get_ffmpeg_exe())
    ffmpeg.filter([ffmpeg.input(inputpath), ffmpeg.input(palettepath)], filter_name='paletteuse').output(
        outputpath, r=fps, loglevel='error').global_args('-hide_banner').overwrite_output().run(cmd=imageio_ffmpeg.get_ffmpeg_exe())


convertFile(sys.argv[1], sys.argv[2], sys.argv[3])
