FROM continuumio/miniconda3

RUN apt-get update && apt-get install -y --no-install-recommends build-essential
RUN conda create -n scenic python=3.6.7
RUN echo "source activate scenic" > ~/.bashrc
ENV PATH /opt/conda/envs/scenic/bin:$PATH
RUN pip install --no-cache-dir --upgrade pyscenic dask==1.0.0 pandas==0.23.4

LABEL version=0.1

# Install dependencies: fwatchdog, yq and porta.sh
RUN apt-get update && apt-get install -y --no-install-recommends curl bash \
    && echo "Pulling watchdog binary from Github." \
    && curl -sSL https://github.com/openfaas/faas/releases/download/0.9.14/fwatchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog \
    && cp /usr/bin/fwatchdog /home/app \
    && echo "Pulling porta.sh from Github." \
    && curl -sSL https://raw.githubusercontent.com/data-intuitive/Portash/master/porta.sh > /usr/bin/porta.sh \
    && chmod +x /usr/bin/porta.sh \
    && echo "Pulling yq from Github." \
    && curl -sSL https://github.com/mikefarah/yq/releases/download/2.2.1/yq_linux_386 > /usr/bin/yq \
    && chmod +x /usr/bin/yq

# fwatchdog config
EXPOSE 8080
ENV fprocess="porta.sh"
ENV write_debug="true"
ENV read_timeout=3600
ENV write_timeout=3600

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1
CMD [ "fwatchdog" ]
