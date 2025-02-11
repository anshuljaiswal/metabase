import React from "react";
import { t } from "ttag";
import MetabaseSettings from "metabase/lib/settings";
import Question from "metabase-lib/Question";
import NativeQueryModal, { useNativeQuery } from "../NativeQueryModal";
import { ModalExternalLink } from "./PreviewQueryModal.styled";

interface PreviewQueryModalProps {
  question: Question;
  onClose?: () => void;
}

const PreviewQueryModal = ({
  question,
  onClose,
}: PreviewQueryModalProps): JSX.Element => {
  const { query, error, isLoading } = useNativeQuery(question);
  const learnUrl = MetabaseSettings.learnUrl("debugging-sql/sql-syntax");

  return (
    <NativeQueryModal
      title={t`Query preview`}
      query={query}
      error={error}
      isLoading={isLoading}
      onClose={onClose}
    >
      {error && (
        <ModalExternalLink href={learnUrl}>
          {t`Learn how to debug SQL errors`}
        </ModalExternalLink>
      )}
    </NativeQueryModal>
  );
};

export default PreviewQueryModal;
