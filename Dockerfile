FROM kasmweb/core-ubuntu-jammy:1.14.0-rolling
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########


RUN apt-get update && apt-get upgrade -y 

RUN mkdir -p /opt/prusaSlicer \
    && cd /opt/prusaSlicer \
    && add-apt-repository universe \
    && apt install -y \
        libfuse2 \
        libwebkit2gtk-4.0-dev \
        gstreamer1.0-libav \
        gstreamer1.0-plugins-bad \
    && wget $(curl -L -s https://api.github.com/repos/prusa3d/PrusaSlicer/releases/latest | grep -oEi "https://(.*)PrusaSlicer-(.*)linux-x64-GTK3-(.*).AppImage") \
    && chmod +x *.AppImage \
    && ./*.AppImage --appimage-extract \
    && rm *.AppImage \
    && mv squashfs-root/* . \
    && rm -rf squashfs-root/ \
    && chown 1000:1000 -R /opt/prusaSlicer

# Set this so that Bambu Studio doesn't complain about
# the CA cert path on every startup
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

COPY PrusaSlicer/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod +x $STARTUPDIR/custom_startup.sh
RUN chmod 755 $STARTUPDIR/custom_startup.sh


# Update the desktop environment to be optimized for a single application
RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
RUN cp /usr/share/extra/backgrounds/bg_kasm.png /usr/share/extra/backgrounds/bg_default.png
RUN apt-get remove -y xfce4-panel

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000